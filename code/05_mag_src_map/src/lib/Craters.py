import pandas as pd

class Craters:
    
    def __init__(self):
        return
    
    
    def loadData(self, path, minDiam=0, maxDiam=1500, extraInfo=True):
        self.path = path
        self.minDiam = minDiam
        self.maxDiam = maxDiam
        
        # read
        self.craters_df = pd.read_csv(path, usecols=[0,1,2,5])
        # rename cols
        # self.craters_df.rename(columns={'CRATER_ID':'id','LAT_CIRC_IMG':'lat','LON_CIRC_IMG':'clon','DIAM_CIRC_IMG':'diam'}, inplace=True)
        self.craters_df.columns = ['id', 'lat', 'clon', 'diam']
        # diameter cut
        self.craters_df = self.craters_df[(self.craters_df['diam'] >= minDiam) & (self.craters_df['diam'] <= maxDiam)].sort_values(by=['diam'])
        # add lon
        self.craters_df['lon'] = self.clon2lon(self.craters_df['clon'])
        # swap clon and lon
        self.craters_df = self.craters_df.iloc[:, [0,4,1,3,2]]
        self.craters_df.columns = ['id', 'lon', 'lat', 'diam', 'clon']
        
        
        # add names, age, and age_error
        if extraInfo:            
            fn = self.getPath(path, '..', 'crater_names_ages.csv')
            extra_df = pd.read_csv(fn)
            
            self.craters_df = self.craters_df.merge(extra_df, how='left', on='id')
            self.craters_df.name.fillna('', inplace=True)
            self.craters_df.age.fillna(-1, inplace=True)
            self.craters_df.age_error.fillna(-1, inplace=True)
            # print(craters_df.to_string())
            
        return
    
    
    def getData(self):
        return self.craters_df
    
    
    def getByName(self,name):
        return self.craters_df.loc[self.craters_df['name'] == name].iloc[0].to_dict()
    
    
    def km2theta(self,km):
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
    
    
    def theta2km(self,theta):
        km = (theta+0.123)/0.0185
        return km
    
    
#############################################

    def lon2clon(self, lon):
        return lon % 360
    def clon2lon(self, clon):
        return ((clon-180) % 360) - 180


    def lat2cola(self, lat):
        return lat % 180
    def cola2lat(self, cola):
        return ((cola-90) % 180) - 90


    def getPath(self, *args):
        """Join all arguments into a single path. Use 'current' as a stand in for path to current file."""
        import os
        args = [os.getcwd() if arg == 'current' else arg for arg in args]
        return os.path.abspath(os.path.join(*args))
