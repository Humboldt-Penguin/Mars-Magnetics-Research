"""
Written by Zain Eris Kamal (zain.eris.kamal@rutgers.edu).
Full repository available here: https://github.com/Humboldt-Penguin/Mars-Magnetics-Research
"""


import math
import numpy as np



import zerisk.GRS
import zerisk.Crust







class HeatCalculator:
    
    """
    private instance variables:
    
    implicit:
    ---------
        GRS : GRS
            Defined by GRS.py
        Crust : Crust
            Defined by Crust.py
        path__datahome : str
            Path from root to the directory within which the data folder either (1) already exists, or (2) will be downloaded.
            
            
    explicit:
    ---------
    """
    
    
    
    

    
    
    
    def __init__(self):
        """Initialize empty HeatCalculator object (no data yet)."""
        return
    
    
    
    
    
    
    
    
    
    
    def download_load_Data(self, path__datahome: str, overwrite: bool = False, verbose: bool = False) -> None:
        """
        DESCRIPTION:
        ------------
            - Downloads and unzips data to `self.path__datahome` if it doesn't already exist there. If it already exists, overwrite if `overwrite==True`, else do nothing.
            - Load data into GRS and Crust objects.
        
        PARAMETERS:
        ------------
            path__datahome : str
                Path from root to the directory within which the data folder either (1) already exists, or (2) will be downloaded.
            overwrite : bool
                If true and data folder already exists, delete the data folder and download again. Else skip the download and inform the user. 
            verbose : bool
                If true, print contents of unzipped data folder. Else do nothing. 
        """
        self.path__datahome = path__datahome
        
        self.GRS = zerisk.GRS.GRS()
        self.GRS.downloadData(self.path__datahome, overwrite=overwrite, verbose=verbose)
        self.GRS.loadData()
        
        self.Crust = zerisk.Crust.Crust()
        self.Crust.downloadData(self.path__datahome, overwrite=overwrite, verbose=verbose)
        self.Crust.loadData(ref_interior_model_int=0)
    
    
    
    
    

    
    
    def GRS_getNanVal(self) -> float:
        return self.GRS.getNanVal()
    
    
    
    
    
    
    
    
    def calc_H(self, lon: float, lat: float, t: float, volatile_adjusted: bool = True) -> float:
        """
        Calculate heat production rate in lithosphere [W/kg?] at a specific coordinate/time due to decay of radiogenic heat producing elements (U238, U235, Th232, K40).

        PARAMETERS:
        -----------
            lon, lat : float
                Coordinates at which to calculate H. These are used to find GRS data.
            time : float
                How many years in the past to calculate H. These are used to calculate elapsed half-lives of radiogenic HPEs.
                Ex: `t=3.4e9` would specify 3.4 billion years in the past.
            volatile_adjusted : bool
                Determine whether or not to normalize GRS radiogenic HPE concentrations to a volatile-free basis. See the next method "getAdjustedConcentration" in the GRS.py class for details.

        RETURN:
        -----------
            H : float
                Heat production rate in lithosphere [W/kg?] at a specific coordinate/time due to decay of radiogenic heat producing elements (U238, U235, Th232, K40).

        METHODS:
        -----------
            - Hahn et al 2011: Martian surface production and crustal heat flow from Mars Odyssey Gamma-Ray spectrometry
            - Turcotte and Schubert 2001: Geodynamics (textbook)    
        """


        thisHPE = HPE

        # get concentrations of each element (these coordinates, current day)
        for element in thisHPE:
            elementname = ''.join([char for char in element if not char.isdigit()]).lower()
            if elementname == 'u':
                concentration = self.GRS.getConcentration(lon, lat, "th", volatile_adjusted) / 3.8
            else:
                concentration = self.GRS.getConcentration(lon, lat, elementname, volatile_adjusted)


            if concentration == self.GRS.getNanVal():
                return self.GRS.getNanVal()
            thisHPE[element]["concentration"] = concentration

        # calculate crustal heat production (these coordinates, `t` years ago)
        H = 0
        for element in thisHPE:
            H += (
                thisHPE[element]["isotopic_frac"] 
                * thisHPE[element]["concentration"] 
                * thisHPE[element]["heat_release_const"] 
                * math.exp((t * math.log(2))/(thisHPE[element]["half_life"]))
            )
        return H
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    def calc_CurieDepths(self, lon: float, lat: float, t: float, q_b_mW: float, curie_temps: list, volatile_adjusted: bool = True) -> list:
        """
        Calculate curie depth [km] at a specific coordinate/time due to decay of radiogenic heat producing elements (U238, U235, Th232, K40). Assume surface temperature is 0 Celsius.

        PARAMETERS:
        -----------
            lon, lat : float
                Coordinates at which to calculate H. These are used to find GRS data.
            time : float
                How many years in the past to calculate H. These are used to calculate elapsed half-lives of radiogenic HPEs.
                    - Ex: `t=3.4e9` would specify 3.4 billion years in the past.
            q_b_mW : float
                Heat flow [mW m^-2] from the lower mantle into the base of the lithosphere. Presently varies between 1.3 and 13.5, average of 7. On ancient Mars, this could have been anything from 20 to 60.
            curie_temps : 1D float array
                The purpose of this function is to find the depth at which the ambient temperature [degrees Celsius!!!] reaches these temperatures.
                    - Ex: `curie_temps=(320,580,670)` would correspond to single domain pyrrhotite, single domain magnetite, and multidomain hematite respectively (Artemieva et al., 2005).
            volatile_adjusted : bool
                Determine whether or not to normalize GRS radiogenic HPE concentrations to a volatile-free basis. See the next method "getAdjustedConcentration" in the GRS.py class for details.

        RETURN:
        -----------
            curie_depths : 1D float array
                Return the depth below the surface at which temperature due to HPE decay reaches the curie points specified as input. 
                The input `curie_temps` will correspond element-wise with the output `curie_depths`, i.e. we ensure len(curie_temps) == len(curie_depths).

        METHODS:
        -----------
            - Hahn et al 2011: Martian surface production and crustal heat flow from Mars Odyssey Gamma-Ray spectrometry
            - Turcotte and Schubert 2001: Geodynamics (textbook)    
        """

        # curie_temps = (320,580,670)

        H = self.calc_H(lon, lat, t, volatile_adjusted) # heat production in crust [W kg^-1]    
        
        ## ensure curie_depths is iterable
        if type(curie_temps) is not list and type(curie_temps) is not tuple:
            curie_temps = (curie_temps,)

        if H == self.GRS.getNanVal():
            return (self.GRS.getNanVal(),)*len(curie_temps)

        rho = self.Crust.getDensity() # density of crust [kg m^-3]


        thickness_crust_m = self.Crust.getThickness(lon, lat) * 1000




        k_cr = 2.5 # thermal conductivity of crust [W m^-1 K^-1]
        k_m = 4 # thermal conductivity of mantle [W m^-1 K^-1]
        q_b = q_b_mW * 10**-3 # basal heat flow, parameter sweep this from 0-50

        def calc_T(depth_km):
            """
            From supplemental text 3 of "Depletion of Heat Producting Elements in the Martian Mantle" by Ojha et al. 2019
            """
            depth_m = depth_km*1000
            if depth_m <= thickness_crust_m:
                T = ((rho * H * depth_m)/(k_cr))*(thickness_crust_m - depth_m/2) + (q_b * depth_m)/(k_cr)
            else:
                left = ((rho * H * thickness_crust_m)/(k_cr))*(thickness_crust_m - thickness_crust_m/2) + (q_b * thickness_crust_m)/(k_cr)
                right = ((rho * H * thickness_crust_m**2)/(2*k_m)) + ((q_b * thickness_crust_m)/(k_m))
                T_0 = left-right

                T = T_0 + ((rho * H * thickness_crust_m**2)/(2*k_m)) + ((q_b * depth_m)/(k_m))
            return T






        curie_depths = []
        error = 0.01

        for curie_temp in curie_temps:
            depth_left = 0
            depth_right = 500
            depth_mid = (depth_right+depth_left)/2

            temp_left = calc_T(depth_left)
            temp_right = calc_T(depth_right)
            temp_mid = calc_T(depth_mid)

            assert temp_left < curie_temp and curie_temp < temp_right, 'erm what the fish'

            while abs( temp_mid - curie_temp ) > error:
                if temp_mid < curie_temp:
                    depth_left = depth_mid
                    temp_left = temp_mid
                else:
                    depth_right = depth_mid
                    temp_right = temp_mid                
                depth_mid = (depth_right+depth_left)/2
                temp_mid = calc_T(depth_mid)

            curie_depths.append(depth_mid)


        return curie_depths
    
    
    
    
    
    
    
    
    
    
    
    
    


    def calc_TempDepthProfile(self, lon, lat, t, q_b_mW, toDepth, volatile_adjusted=True):
        """
        Make a temperature vs depth profile of the lithosphere for a crater

        (verify plotting works with this rewritten code)
        """
        
        H = self.calc_H(lon, lat, t, volatile_adjusted) # heat production in crust [W kg^-1]    

        # i address nanvals later on to make sure it's an arraylike :)
        # if H == thisGRS.getNanVal():
        #     return thisGRS.getNanVal()

        rho = self.Crust.getDensity() # density of crust [kg m^-3]

        # thickness_crust_m = 40e3 # from random map i found online -- eventually automate this!
        thickness_crust_m = self.Crust.getThickness(lon, lat) * 1000


        k_cr = 2.5 # thermal conductivity of crust [W m^-1 K^-1]
        k_m = 4 # thermal conductivity of mantle [W m^-1 K^-1]
        q_b = q_b_mW * 10**-3 # basal heat flow, parameter sweep this from 0-50


        def calc_T(depth_km):
            depth_m = depth_km*1000
            if depth_m <= thickness_crust_m:
                T = ((rho * H * depth_m)/(k_cr))*(thickness_crust_m - depth_m/2) + (q_b * depth_m)/(k_cr)
            else:
                left = ((rho * H * thickness_crust_m)/(k_cr))*(thickness_crust_m - thickness_crust_m/2) + (q_b * thickness_crust_m)/(k_cr)
                right = ((rho * H * thickness_crust_m**2)/(2*k_m)) + ((q_b * thickness_crust_m)/(k_m))
                T_0 = left-right

                T = T_0 + ((rho * H * thickness_crust_m**2)/(2*k_m)) + ((q_b * depth_m)/(k_m))
            return T


        depths_km = np.arange(0, toDepth, 0.1)

        if H == self.GRS.getNanVal():
            temps_C = [self.GRS.getNanVal() for d in depths_km]
        else:
            temps_C = [calc_T(d) for d in depths_km]

        # vfunc_calc_T = np.vectorize(calc_T)
        # temps_C = vfunc_calc_T(depths_m)

        return (depths_km, temps_C)
    
    


#######################################################################################################################################

HPE = {
    # Constants from:
    #     - "Amagmantic Hydrothermal Systems on Mars from Radiogenic Heat", by Ojha et al. 2021,
    #     - "Geodynamics", by Turcotte & Schubert 2014.
    "U238": {
        "isotopic_frac": 0.9928, # natural abundance of this isotope relative to all isotopes of this element
        "heat_release_const": 9.46e-5, # net energy per unit mass [W/kg]
        "half_life": 4.47e9
    },
    "U235": {
        "isotopic_frac": 0.0071,
        "heat_release_const": 5.69e-4,
        "half_life": 7.04e8
    },
    "Th232": {
        "isotopic_frac": 1.00,
        "heat_release_const": 2.64e-5,
        "half_life": 1.40e10
    },
    "K40": {
        "isotopic_frac": 1.191e-4,
        "heat_release_const": 2.92e-5,
        "half_life": 1.25e9
    }
}
