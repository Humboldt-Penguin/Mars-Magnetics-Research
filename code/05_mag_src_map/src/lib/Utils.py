class Utils:
    
    verbose = False
    
    def __init__(self, verbose):
        self.verbose = verbose
        return

    
    ###############################################
    ## Dealing with coordinates
    ###############################################

    def lon2clon(self, lon):
        return lon % 360
    def clon2lon(self, clon):
        return ((clon-180) % 360) - 180


    def lat2cola(self, lat):
        return lat % 180
    def cola2lat(self, cola):
        return ((cola-90) % 180) - 90


    
    ###############################################
    ## System paths
    ###############################################

    def getPath(self, *args):
        """Join all arguments into a single path. Use 'current' as a stand in for path to current file."""
        import os
        args = [os.getcwd() if arg == 'current' else arg for arg in args]
        return os.path.abspath(os.path.join(*args))
    
    

