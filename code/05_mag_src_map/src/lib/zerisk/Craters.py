"""
Written by Zain Eris Kamal (zain.eris.kamal@rutgers.edu).
Full repository available here: https://github.com/Humboldt-Penguin/Mars-Magnetics-Research
"""

import pandas as pd

import zerisk.Utils as utils
import zerisk.DataDownloader as dd

class Craters:
    """
    Class allows you to download and manage crater data.
    
    See README in downloaded folder to find more information on the data itself.
    """
    
    """
    implicit private instance variables:
        path__datahome
        craters_df
        minDiam
        maxDiam
    """
    
    gdrive_url = r"https://drive.google.com/drive/folders/1BcPbvBUJPO74O2MlZ-jRwKpV_VrCTKTy?usp=sharing"    

    

    
    
    
    
    def __init__(self) -> None:
        """
        Initialize empty GRS object (no data yet).
        """
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
        dd.download_latest(path__datahome=self.path__datahome, data_name='craters', url=self.gdrive_url, overwrite=overwrite, verbose=verbose)
        return
    
    
    
    
    
    
    
    
    
    def loadData(self, minDiam: float = 0, maxDiam: float = 1500, extraInfo: bool = True) -> None:
        """
        DESCRIPTION:
        ------------
            Read crater data from spreadsheet into `self.craters_df`. Format is a pandas dataframe.
        
        PARAMETERS:
        ------------
            minDiam : float
                Minimum diameter (km) of craters loaded into dataframe.
            maxDiam : float
                Maximum diameter (km) of craters loaded into the dataframe.
            extraInfo : bool
                If true, add information from `crater_names_ages.csv` to `self.craters_df`.
        """
        
        
        
        self.minDiam = minDiam
        self.maxDiam = maxDiam
        
        # read
        self.craters_df = pd.read_csv(utils.getPath(self.path__datahome, 'craters', 'Catalog_Mars_Release_2020_1kmPlus_FullMorphData.csv'), usecols=[0,1,2,5])
        # rename cols
        # self.craters_df.rename(columns={'CRATER_ID':'id','LAT_CIRC_IMG':'lat','LON_CIRC_IMG':'clon','DIAM_CIRC_IMG':'diam'}, inplace=True)
        self.craters_df.columns = ['id', 'lat', 'clon', 'diam']
        # diameter cut
        self.craters_df = self.craters_df[(self.craters_df['diam'] >= minDiam) & (self.craters_df['diam'] <= maxDiam)].sort_values(by=['diam'])
        # add lon
        self.craters_df['lon'] = utils.clon2lon(self.craters_df['clon'])
        # swap clon and lon (more convenient display)
        self.craters_df = self.craters_df.iloc[:, [0,4,1,3,2]]
        self.craters_df.columns = ['id', 'lon', 'lat', 'diam', 'clon']
        
        
        # add names, age, and age_error
        if extraInfo:            
            fn = utils.getPath(self.path__datahome, 'craters', 'crater_names_ages.csv')
            extra_df = pd.read_csv(fn)
            
            self.craters_df = self.craters_df.merge(extra_df, how='left', on='id')
            self.craters_df.name.fillna('', inplace=True)
            self.craters_df.age.fillna(-1, inplace=True)
            self.craters_df.age_error.fillna(-1, inplace=True)
            # print(craters_df.to_string())
            
        return
    
    
    
    
    def getData(self) -> pd.DataFrame:
        return self.craters_df
    
    
    def getByName(self, name: str) -> dict:
        return self.craters_df.loc[self.craters_df['name'] == name].iloc[0].to_dict()
    
    def getByID(self, id: str) -> dict:
        return self.craters_df.loc[self.craters_df['id'] == id].iloc[0].to_dict()
        
    
    
    def km2theta(self, km: float) -> float:
        """
        Converts a crater's diameter from kilometers to degrees. 

        This equation is obtained by looking at many craters on JMars and
        roughly measuring the angular separation between the left and right
        edges. We then plot this against diameter in km (accessed from
        generate_crater_locations.m) and then finding the line of best fit,
        which is linear. Rough calculations here:
            https://docs.google.com/spreadsheets/d/1Ylr_Oowq_jV1KNXEGuSvXbWNbPZNGUQF1jjv2eTC7Jg/edit?usp=sharing
        """
        theta = 0.0185*km - 0.123
        return theta
    
    
    def theta2km(self, theta: float) -> float:
        km = (theta+0.123)/0.0185
        return km
