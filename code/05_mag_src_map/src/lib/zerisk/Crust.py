"""
Written by Zain Eris Kamal (zain.eris.kamal@rutgers.edu).
Full repository available here: https://github.com/Humboldt-Penguin/Mars-Magnetics-Research
"""

import os

import numpy as np


import zerisk.Utils as utils
import zerisk.DataDownloader as dd




class Crust:
    """
    Class allows you to:
        (1) Download crustal thickness from "InSight Crustal Thickness Archive" code by Mark A. Wieczorek (https://zenodo.org/record/6477509).
        (2) Get crustal thickness values at exact coordinates by linearly interpolating between the four nearest points. 
    
    See README in downloaded folder to find more information on the data itself.
    """
    
    
    
    
    
    
    
    
    
    
    """
    private instance variables:
    
    implicit:
    ---------
        path__datahome : str
            Path from root to the directory within which the data folder either (1) already exists, or (2) will be downloaded.
        dat : 1D float array (np.ndarray)
            1D array representation of 2D data read from .npy file representing crustal thickness data.
        spacing : float
            Desired grid spacing in degrees. Ex: spacing=0.5 means crustal thickness is exactly defined at 0, 0.5, 1, 1.5, etc.
        latrange, clonrange, lonrange : 1D float array (np.ndarray)
            Longitude/latitude values for which crustal thickness values are exactly defined by the dataset. I.e., if lonrange and latrange define a grid, then crustal thickness values are exactly defined at the intersection of these grid lines.
            
            
    explicit:
    ---------
        gdrive_url : str
            URL from which latest dataset is downloaded using `DataDownloader.py`.
        crustal_density : float
            From Gong & Wieczorek: "In Figure 8, we plot the depth of magnetization as a function of crustal thickness. Here we use a crustal thickness model of Wieczorek et al. (2020) which assumes a uniform crustal density of 2,900 kg and a minimum crustal thickness of 5 km within the Isidis impact basin."
        dict_ref_interior_model : dict
            When running `make-grids.py` from Wieczorek's code, you are first prompted to choose a "reference interior model" from a list of 16 options, each of which is assigned an integer. This int -> str map is included in this dictionary for the user to specify when loading data. Note that not all options will be available for certain input parameters
    """
    
    
    gdrive_url = r"https://drive.google.com/drive/folders/1WUqEStBxPd6ETVlStLmDJYA122YPeFeA?usp=sharing"
    
    crustal_density = 2900 # [kg m^-3]

    def getDensity(self):
        return self.crustal_density
    

    dict_ref_interior_model = {
        0: "DWThot",
        1: "DWThotCrust1",
        2: "DWThotCrust1r",
        3: "EH45Tcold",
        4: "EH45TcoldCrust1",
        5: "EH45TcoldCrust1r",
        6: "EH45ThotCrust2",
        7: "EH45ThotCrust2r",
        8: "LFAK",
        9: "SANAK",
        10: "TAYAK",
        11: "DWAK",
        12: "ZG_DW",
        13: "YOTHotRc1760kmDc40km",
        14: "YOTHotRc1810kmDc40km",
        15: "Khan2022",
    }

    invalid_ref_interior_model = [8,10,11,12,13,14,15] # see postscript in `crustal_thickness/README.txt` "SOURCE" section
    
    
    
    
    
    
    
    
    
    
    
    def __init__(self):
        """Initialize empty Crustal Thickness object (no data yet)."""
        return
    
    
    
    
    
    
    
    
    
    
    
    def downloadData(self, path__datahome: str, overwrite: bool = False, verbose: bool = False) -> None:
        """
        DESCRIPTION:
        ------------
            Downloads and unzips data to `self.path__datahome` if it doesn't already exist there. If it already exists, overwrite if `overwrite==True`, else do nothing.
        
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
        dd.download_latest(path__datahome=self.path__datahome, data_name='crustal_thickness', url=self.gdrive_url, overwrite=overwrite, verbose=verbose)
        return
    
    
    
    
    
    
    
    
    
    
    
    def loadData(self, ref_interior_model_int: int = None, ref_interior_model_str: str = None) -> None:
        """
        DESCRIPTION:
        ------------
            Load crustal thickness data into numpy array.
        
        PARAMETERS:
        ------------ 
            ref_interior_model_int : int (optional)
                See `dict_ref_interior_model`.
            ref_interior_model_str : str (optional)
                See `dict_ref_interior_model`.
        """
        
        self.spacing = 0.1 # spacing # this was previously an input for loadData, but I only ever use 0.1, never 0.5.
        self.latrange = np.around(np.arange(90,-90-self.spacing,-self.spacing), decimals=3)
        self.clonrange = np.around(np.arange(0,360+self.spacing,self.spacing), decimals=3)
        self.lonrange = utils.clon2lon(self.clonrange)
        
        

        if ref_interior_model_int != None:
            if ref_interior_model_int in self.invalid_ref_interior_model:
                raise Exception("Crustal thickness data does not exist for this reference interior model. Either change parameters or manually generate the data using Wieczorek's script and my reduction script. See `crustal_thickness/README.txt` for more information.")
            ref_interior_model_str = self.dict_ref_interior_model[ref_interior_model_int]
        
        if ref_interior_model_str == None:
            raise Exception('Please provide either an integer or explicit name of a reference interior model.')

        # Mars-thick-EH45TcoldCrust1-30-2900-2900__shortened__grid=0.1.npy
        filename = (
            'Mars-thick-' + 
            ref_interior_model_str + 
            '-30-2900-2900__shortened__grid=' + 
            str(self.spacing) + 
            '.npy'
        )
        path = utils.getPath(self.path__datahome, 'crustal_thickness', filename)
        if not os.path.isfile(path):
            raise Exception(f"Crustal thickness data does not exist for these parameters. Either change parameters or manually generate the data using Wieczorek's script and my reduction script. See `crustal_thickness/README.txt` for more information. \nThe file you tried to access is {path}")
        self.dat = np.load(path)
        
        return
    
    
    
    
    
    
    
    
    
    
        
        
        
        
        
        
    def checkCoords(self, lon: float, lat: float) -> None:
        """
        DESCRIPTION:
        ------------
            Raise an error if given coordinates aren't within the valid range:
                -180 <= lon <= 180
                -90 <= lat <= lat
                
                
        """
        
        assert (-90 <= lat and lat <= 90), f'ERRROR: latitude {lat} out of bounds.'
        # assert (0 <= clon and clon <= 360), f'ERRROR: colongitude {clon} out of bounds.'
        assert (-180 <= lon and lon <= 180), f'ERRROR: longitude {lon} out of bounds.'
        
        return
    
    
    
    
    
    
    
    
    
    def __getExactThickness(self, clon: float, lat: float) -> float:
        """
        DESCRIPTION:
        ------------
            Assuming the crustal thickness is exactly defined at the given coordinates by the dataset, provide the exact value [km] from the dataset. Otherwise raise an error.
        """
        
        # clon = lon2clon(lon)
        lon = utils.clon2lon(clon)
        self.checkCoords(lon,lat)
        try:
            i_lat = ( np.where(np.abs(self.latrange-lat) < 1e-5) )[0][0]
            i_clon = ( np.where(np.abs(self.clonrange-clon) < 1e-5) )[0][0]
            i = i_lat*self.clonrange.size + i_clon
            return self.dat[i]
        except IndexError:
            raise Exception('ERROR: interpolation is required to crustal thickness at this value -- use `getThickness` instead.')

            
            
            
            
            
            
            
            
            

    def getThickness(self, lon: float, lat: float) -> float:
        """
        DESCRIPTION:
        ------------
            Get the crustal thickness [km] at any coordinates, whether it's exactly defined by the dataset or requires bilinear interpolation between the four nearest points.
        """

        self.checkCoords(lon,lat)    
        clon = utils.lon2clon(lon)


        if clon in self.clonrange and lat in self.latrange: # clon and lat fall perfectly on grid
            finalval = self.__getExactThickness(clon,lat)
            return finalval
        elif clon in self.clonrange and lat not in self.latrange: # perfectly falls on clongitude line, not lat
            # print('e1')
            lattop, latbottom = self.latrange[(np.where(np.abs(self.latrange-lat) < self.spacing))[0]]

            topval = self.__getExactThickness(clon, lattop)
            bottomval = self.__getExactThickness(clon, latbottom)

            # topweight = abs(lat-lattop)/spacing
            # bottomweight = 1-topweight
            bottomweight = abs(lat-lattop)/self.spacing
            topweight = abs(lat-latbottom)/self.spacing

            finalval = topval*topweight + bottomval*bottomweight
            return finalval
        elif clon not in self.clonrange and lat in self.latrange: # perfectly falls on latitude line, not clon
            # print('e2')
            clonleft, clonright = self.clonrange[(np.where(np.abs(self.clonrange-clon) < self.spacing))[0]]
            # lonleft, lonright = clon2lon(clonleft, clonright)

            leftval = self.__getExactThickness(clonleft, lat)
            rightval = self.__getExactThickness(clonright, lat)

            # leftweight = abs(clon-clonleft)/spacing
            # rightweight = abs(clon-clonright)/spacing
            rightweight = abs(clon-clonleft)/self.spacing
            leftweight = abs(clon-clonright)/self.spacing

            finalval = leftval*leftweight + rightval*rightweight
            return finalval        
        else: # falls in the middle of 4 points
            # print('e3')
            lattop, latbottom = self.latrange[(np.where(np.abs(self.latrange-lat) < self.spacing))[0]]
            clonleft, clonright = self.clonrange[(np.where(np.abs(self.clonrange-clon) < self.spacing))[0]]
            # lonleft, lonright = clon2lon(clonleft, clonright)

            topleft = self.__getExactThickness(clonleft, lattop)
            topright = self.__getExactThickness(clonright, lattop)
            bottomleft = self.__getExactThickness(clonleft, latbottom)
            bottomright = self.__getExactThickness(clonright, latbottom)

            # leftweight = abs(clon-clonleft)/spacing
            # rightweight = abs(clon-clonright)/spacing
            rightweight = abs(clon-clonleft)/self.spacing
            leftweight = abs(clon-clonright)/self.spacing

            topinterp = topleft*leftweight + topright*rightweight
            bottominterp = bottomleft*leftweight + bottomright*rightweight

            # topweight = abs(lat-lattop)/spacing
            # bottomweight = 1-topweight
            bottomweight = abs(lat-lattop)/self.spacing
            topweight = abs(lat-latbottom)/self.spacing

            finalval = topinterp*topweight + bottominterp*bottomweight
            return finalval
        
        
        
        
        
        
        
    def getAvgThickness(self, lon, lat, radius=1):
        
        # lon +/- radius (ie angular)
        
        lons = np.linspace(lon-radius,lon+radius,100)
        lats = np.linspace(lat-radius,lat+radius,100)
        
        total = 0
        
        for i in lons:
            for j in lats:
                total += self.getThickness(i,j)
        return (total / (lons.shape[0] * lats.shape[0]))
        
        
        



    
    
    
    
    

###########################
# General helper functions


'''
These were moved to the Utils.py class

def lon2clon(lon: float) -> float:
    """
    Converts longitude value in range [-180,180] to cyclical longitude (aka colongitude) in range [180,360]U[0,180], in degrees.
    
    Using longitude [-180,180] puts Arabia Terra in the middle.
    Using cyclical longitude [0,360] puts Olympus Mons in the middle.
    
    """
    return lon % 360


def clon2lon(clon: float) -> float:
    """
    Converts cyclical longitude (aka colongitude) in range [0,360] to longitude in range [0,180]U[-180,0].
    
    Using longitude [-180,180] puts Arabia Terra in the middle.
    Using cyclical longitude [0,360] puts Olympus Mons in the middle.
    """
    return ((clon-180) % 360) - 180


def lat2cola(lat: float) -> float:
    """
    Converts latitude value in range [-90,90] to cyclical latitude (aka colatitude) in range [0,180], in degrees.    
    """
    return lat % 180

def cola2lat(cola: float) -> float:
    """
    Converts cyclical latitude (aka colatitude) in range [0,180] to latitude value in range [-90,90], in degrees.    
    """
    return ((cola-90) % 180) - 90
'''