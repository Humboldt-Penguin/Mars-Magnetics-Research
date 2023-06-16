"""
Written by Zain Eris Kamal (zain.eris.kamal@rutgers.edu).
Full repository available here: https://github.com/Humboldt-Penguin/Mars-Magnetics-Research
"""

import os
import re

import numpy as np
import pandas as pd


import zerisk.Utils as utils
import zerisk.DataDownloader as dd




class Crust:
    '''
    Class allows you to:
        (1) Download crustal thickness generated from "InSight Crustal Thickness Archive" code by Mark A. Wieczorek (https://zenodo.org/record/6477509) (with some alterations, see README for more information).
        (2) Get crustal thickness values at exact coordinates by linearly interpolating between the four nearest points. 
    
    See README in downloaded folder to find more information on the data itself.
    '''
    
    



    ######################################################################
    ''' constant class variables '''
    



    gdrive_url: str = r"https://drive.google.com/drive/folders/1WUqEStBxPd6ETVlStLmDJYA122YPeFeA?usp=sharing"
    # URL from which latest dataset is downloaded using `DataDownloader.py`.
    




    crustal_density: int = 2900 # [kg m^-3]
    # From Gong & Wieczorek: "In Figure 8, we plot the depth of magnetization as a function of crustal thickness. Here we use a crustal thickness model of Wieczorek et al. (2020) which assumes a uniform crustal density of 2,900 kg and a minimum crustal thickness of 5 km within the Isidis impact basin."
    
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
    # When running `make-grids.py` from Wieczorek's code, you are first prompted to choose a "reference interior model" from a list of 16 options, each of which is assigned an integer. This int -> str map is included in this dictionary for the user to specify when loading data. Note that not all options will be available for certain input parameters












    ######################################################################
    ''' instance class variables '''
    # (if you're catching an AttributeError relating to one of these variables, it likely hasn't been assigned yet with something like `self.var=val``)




    path__datahome : str
    # Path from root to the directory within which the data folder either (1) already exists, or (2) will be downloaded.




    dat: np.ndarray
    # 1D array representation of 2D data read from .npy file representing crustal thickness data.



    grid_spacing: float
    # Desired grid spacing in degrees. Ex: spacing=0.5 means crustal thickness is exactly defined at 0, 0.5, 1, 1.5, etc.





    rho_north: int
    rho_south: int
    # Crustal density [kg/m^3] in north/south of dichotomy





    latrange: np.ndarray
    clonrange: np.ndarray
    lonrange: np.ndarray
    # Longitude/latitude values for which crustal thickness values are exactly defined by the dataset -- i.e., if lonrange and latrange define a grid, then crustal thickness values are exactly defined at the intersection of these grid lines.
    








    ref_interior_model_int: int
    # See `dict_ref_interior_model` variable for more information. This is the reference interior model used for the current crustal thickness dataset.

    def getRefInteriorModel_int(self) -> int:
        return self.ref_interior_model_int
    def getRefInteriorModel_str(self) -> str:
        return self.dict_ref_interior_model[self.ref_interior_model_int]
    
    
    
    
    
    









    ######################################################################
    ''' main body '''

    
    
    
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










    def getAvailableDatasets(self) -> pd.DataFrame:
        """
        DESCRIPTION:
        ------------
            See all available crustal thickness models.

        RETURN:
        -----------
            df : pd.DataFrame
                Dataframe where each row corresponds to a possible dataset. 
                Columns are:
                - 'Reference interior model (int)'
                - 'Reference interior model (str)'
                - 'Seismic thickness at InSight landing [km]'
                - 'rho_north [kg/m3]'
                - 'rho_south [kg/m3]'
                - 'grid spacing [deg]'
                - 'filename'
        
        """
    
    
        files = os.listdir(utils.getPath(self.path__datahome, 'crustal_thickness'))

        dat = {
            'Reference interior model (int)': [],
            'Reference interior model (str)': [],
            'Seismic thickness at InSight landing [km]': [],
            'rho_north [kg/m3]': [],
            'rho_south [kg/m3]': [],
            'grid spacing [deg]': [],
            'filename': [],
        }


        def findnth(haystack, needle, n):
            parts= haystack.split(needle, n+1)
            if len(parts)<=n+1:
                return -1
            return len(haystack)-len(parts[-1])-len(needle)

        def get_key_by_value(dictionary, value):
            for key, val in dictionary.items():
                if val == value:
                    return key
            return None


        for file in files:
            if 'Mars-thick' not in file or '.npy' not in file: continue


            dat['filename'].append(file)

            a = file[ findnth(file,'-',1)+1 : findnth(file,'-',2) ]
            dat['Reference interior model (str)'].append(a)

            b = get_key_by_value(self.dict_ref_interior_model, a)
            dat['Reference interior model (int)'].append(b)
            
            c = int(file[ findnth(file,'-',2)+1 : findnth(file,'-',3) ])
            dat['Seismic thickness at InSight landing [km]'].append(c)
            
            d = int(file[ findnth(file,'-',3)+1 : findnth(file,'-',4) ])
            dat['rho_south [kg/m3]'].append(d)
            
            e = int(file[ findnth(file,'-',4)+1 : findnth(file,'__',0) ])
            dat['rho_north [kg/m3]'].append(e)
            
            f = float(file[ findnth(file,'=',0)+1 : findnth(file,'.npy',0) ])
            dat['grid spacing [deg]'].append(f)



        df = pd.DataFrame(dat)

        return df
    
    
    
    








    def loadData(self, index:int = None, filename:str = None) -> None:
        """
        DESCRIPTION:
        ------------
            Load crustal thickness data into numpy array (option 1/2 for loading data).

            Intended use: User would like to work with a subset of crustal thickness models according to some criteria, e.g. uniform crustal density. They call `getAvailableDatasets`, do programmatic filtering to find a set of indices, then loop through these indices. In each iteration, they call this function to load the respective crustal thickness modle and then carry out the desired analysis.

        
        PARAMETERS:
        ------------ 
            index : int
                Index corresponding to the first column (row number) from the pandas dataset returned by `getAvailableDatasets`.  
            filename : str
                meow
        """

        df = self.getAvailableDatasets()


        if index!=None and filename!=None:
            raise Exception('Please provide either an index or a filename, not both.')
        elif index!=None:
            row = df.iloc[index]
        elif filename!=None:
            row = df.loc[df['filename'] == filename]
        else:
            raise Exception('Please provide either an index or a filename.')


        self.ref_interior_model_int = row['Reference interior model (int)'].values[0]

        self.rho_north = row['rho_north [kg/m3]'].values[0]
        self.rho_south = row['rho_south [kg/m3]'].values[0]

        self.grid_spacing = row['grid spacing [deg]'].values[0]
        self.latrange = np.around(np.arange(90,-90-self.grid_spacing,-self.grid_spacing), decimals=3)
        self.clonrange = np.around(np.arange(0,360+self.grid_spacing,self.grid_spacing), decimals=3)
        self.lonrange = utils.clon2lon(self.clonrange)

        filename = row['filename'].values[0]
        path = utils.getPath(self.path__datahome, 'crustal_thickness', filename)
        self.dat = np.load(path)










    
    
    
        
        
        
        
        
        
    def checkCoords(self, lon: float, lat: float) -> None:
        """
        DESCRIPTION:
        ------------
            Raise an error if given coordinates aren't within the valid range:
                -180 <= lon <= 180
                -90 <= lat <= lat
        """
        
        if (lat < -90 or lat > 90):
            raise Exception(f'ERRROR: latitude {lat} out of bounds.')
        if (lon < -180 or lon > 180):
            raise Exception(f'ERRROR: longitude {lon} out of bounds.')

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
            lattop, latbottom = self.latrange[(np.where(np.abs(self.latrange-lat) < self.grid_spacing))[0]]

            topval = self.__getExactThickness(clon, lattop)
            bottomval = self.__getExactThickness(clon, latbottom)

            # topweight = abs(lat-lattop)/spacing
            # bottomweight = 1-topweight
            bottomweight = abs(lat-lattop)/self.grid_spacing
            topweight = abs(lat-latbottom)/self.grid_spacing

            finalval = topval*topweight + bottomval*bottomweight
            return finalval
        elif clon not in self.clonrange and lat in self.latrange: # perfectly falls on latitude line, not clon
            # print('e2')
            clonleft, clonright = self.clonrange[(np.where(np.abs(self.clonrange-clon) < self.grid_spacing))[0]]
            # lonleft, lonright = clon2lon(clonleft, clonright)

            leftval = self.__getExactThickness(clonleft, lat)
            rightval = self.__getExactThickness(clonright, lat)

            # leftweight = abs(clon-clonleft)/spacing
            # rightweight = abs(clon-clonright)/spacing
            rightweight = abs(clon-clonleft)/self.grid_spacing
            leftweight = abs(clon-clonright)/self.grid_spacing

            finalval = leftval*leftweight + rightval*rightweight
            return finalval        
        else: # falls in the middle of 4 points
            # print('e3')
            lattop, latbottom = self.latrange[(np.where(np.abs(self.latrange-lat) < self.grid_spacing))[0]]
            clonleft, clonright = self.clonrange[(np.where(np.abs(self.clonrange-clon) < self.grid_spacing))[0]]
            # lonleft, lonright = clon2lon(clonleft, clonright)

            topleft = self.__getExactThickness(clonleft, lattop)
            topright = self.__getExactThickness(clonright, lattop)
            bottomleft = self.__getExactThickness(clonleft, latbottom)
            bottomright = self.__getExactThickness(clonright, latbottom)

            # leftweight = abs(clon-clonleft)/spacing
            # rightweight = abs(clon-clonright)/spacing
            rightweight = abs(clon-clonleft)/self.grid_spacing
            leftweight = abs(clon-clonright)/self.grid_spacing

            topinterp = topleft*leftweight + topright*rightweight
            bottominterp = bottomleft*leftweight + bottomright*rightweight

            # topweight = abs(lat-lattop)/spacing
            # bottomweight = 1-topweight
            bottomweight = abs(lat-lattop)/self.grid_spacing
            topweight = abs(lat-latbottom)/self.grid_spacing

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
        
        
        

