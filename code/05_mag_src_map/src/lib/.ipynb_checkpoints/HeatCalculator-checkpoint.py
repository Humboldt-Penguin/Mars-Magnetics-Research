import math

class HeatCalculator:
    
    def __init__(self, GRS=None, Crust=None):
        self.GRS = GRS
        self.Crust = Crust
        return
    
    def setGRS(self, GRS):
        self.GRS = GRS
        return
    
    def setCrust(self, Crust):
        self.Crust = Crust
        return
    
    
    def calc_H(self, lon, lat, t, volatile_adjusted=True):
        """
        Calculate heat production rate in lithosphere [W/kg?] at a specific coordinate/time due to decay of radiogenic heat producing elements (U238, U235, Th232, K40).

        PARAMETERS:
            XXX GRS : GRS type object
                XXX Contains elemental abundances from GRS orbiter.
            lon, lat : float
                Coordinates at which to calculate H. These are used to find GRS data.
            time : float
                How many years in the past to calculate H. These are used to calculate elapsed half-lives of radiogenic HPEs.
                Ex: `t=3.4e9` would specify 3.4 billion years in the past.
            volatile_adjusted : bool
                Determine whether or not to normalize GRS radiogenic HPE concentrations to a volatile-free basis. See the next method "getAdjustedConcentration" in the GRS.py class for details.

        RETURN:
            H : float
                Heat production rate in lithosphere [W/kg?] at a specific coordinate/time due to decay of radiogenic heat producing elements (U238, U235, Th232, K40).

        METHODOLOGIES:
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
