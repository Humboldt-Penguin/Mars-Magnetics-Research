import os
import matplotlib.pyplot as plt
import numpy as np

class GRS:
    
    nanval = -1e-10
    path_src = ''
    
    
    def __init__(self, path_src):
        self.path_src = path_src
        """
        Initialize empty GRS object (no data yet).
        """
        return
    
    
    
    
    def loadData(self):
        """
        Load GRS data for all elements from data files. 
        
        Data downloaded from `getdata.sh` script; see `GRS/README.txt` for descriptions of data products.
        
        Assumes the following file layout:
            .
            └── src/
                ├── data/
                │   └── GRS/
                │       ├── smoothed/
                │       └── unsmoothed/
                ├── main/
                │   └── main.py
                ├── lib/
                │   ├── GRS.py
                │   └── __init__.py
                └── getdata.sh

        [tree diagram made with tree.nathanfriend.io/]
        """
        
        
        
        # path_datafolder = os.path.abspath(
        #     os.path.join(
        #         os.getcwd(), 
        #         os.pardir,   # navigate to src
        #         "data/GRS/smoothed"   # adjust smoothed/unsmoothed as needed
        #     )
        # )
        # print(os.getcwd())
        
        path_datafolder = os.path.abspath(os.path.join(self.path_src, "data/GRS/smoothed"))

        
        self.data = []
              
        for datafilename in (os.listdir(path_datafolder)):            
            if ".tab" in datafilename:
                # print(datafilename)

                # read file
                datafile = open(os.path.abspath(os.path.join(path_datafolder, datafilename)), 'r')
                rawdata = datafile.readlines()
                datafile.close()

                # populate lon/lat values if first time
                if self.data == []: # populate lon/lat values
                    # loop setups
                    prevlat = None
                    thisline = []
                    for rawdataline in rawdata:
                        rawdataline = rawdataline.split()
                        thislat = float(rawdataline[0])
                        thisclon = float(rawdataline[1])
                        thiscola = lat2cola(thislat)
                        thislon = clon2lon(thisclon)
                        # thisconc = rawdataline[2]
                        if thislat != prevlat and prevlat != None:
                            self.data.append(thisline)
                            thisline = []
                        thisline.append({"lon": thislon, "lat": thislat, "clon": thisclon, "cola": thiscola})
                        prevlat = thislat
                    self.data.append(thisline)

                # populate data values                
                elementname = datafilename[:datafilename.index("_")]
                counter = 0
                for i in range(len(self.data)):
                    for j in range(len(self.data[0])):
                        # rawdataline = rawdataline.split()
                        thisconc = float(rawdata[counter].split()[2])
                        self.data[i][j][elementname] = thisconc if thisconc != 9999.999 else self.nanval
                        counter += 1
                        
        ## adjust longitude (realign to look like my qgis lol)
        lons = []
        for i in range(len(self.data[0])):
            lons.append(self.data[0][i]["lon"])
        # print(lons)
        for i in range(len(lons)):
            if lons[i] < 0:
                break
        for k in range(len(self.data)):
            self.data[k] = self.data[k][i:] + self.data[k][:i]
        return
    
    
    
    
    
    
    # def fixUnits(self):
    #     # put wt% in terms of decimal proportions (1% -> 0.01, ie 10e-2)
    #     # put ppm for Th to decimal proportions (1 ppm -> 0.000001, ie 10e-6)
    #     for lat in range(len(self.data)):
    #         for lon in range(len(self.data[0])):
    #             for key in self.data[lat][lon]:
    #                 if key == "th":
    #                     self.data[lat][lon][key] *= 10e-6
    #                 elif key != "kvsth":
    #                     self.data[lat][lon][key] *= 10e-2
    #     return





    # def visualize(self, elementname):
    #     test = []
    #     for i in range(len(self.data)):
    #         newline = []
    #         for j in range(len(self.data[0])):
    #             val = self.data[i][j][elementname]
    #             newline.append(val if val < 9000 else self.nanval)
    #             # print
    #         test.append(newline)
    #     plt.imshow(test[::-1], cmap="jet")
    #     plt.colorbar()
    #     return





    def visualize(self, elementname):
        """
        Plot the GRS concentration map for a certain element. For reference, Olympus Mons is on the left.
        """

        test = []
        for i in range(len(self.data)):
            newline = []
            for j in range(len(self.data[0])):
                val = self.data[i][j][elementname]
                newline.append(val if val < 9000 else self.nanval)
                # print
            test.append(newline)
        
        fig, ax = plt.subplots(1,1,figsize=(7,5))
        im = ax.imshow(test[::-1], cmap="jet")
        # ax.invert_yaxis()
        cax = fig.add_axes([ax.get_position().x1+0.02,ax.get_position().y0,0.02,ax.get_position().height])
        plt.colorbar(im, cax=cax)
        plt.show()
        
        
        
        
    
    def getConcentration(self, lon, lat, elementname, normalized = False):
        """
        Get the concentration of an element at the desired coordinate. Units in weight percent (Wt%) -- i.e. a 5% concentration would correspond to a return value of 0.05.
        
        PARAMETERS:
            normalized (bool): Determine whether or not to normalize to a volatile-free basis. See the next method "getAdjustedConcentration" for details.
        """

        
        if normalized:
            return self.__getAdjustedConcentration(lon, lat, elementname)
        else:
            clon = lon2clon(lon)
            cola = lat2cola(lat)

            ## get lon/clon/lat/cola lists for easy searching
            
            lons = []
            for i in range(len(self.data[0])):
                lons.append(self.data[0][i]["lon"])
            # print(lons)
            clons = [lon2clon(lon) for lon in lons]
            # print(clons)
            
            lats = []
            for i in range(len(self.data)):
                lats.append(self.data[i][0]["lat"])
            # print(lats)
            colas = [lat2cola(lat) for lat in lats]
            # print(colas)

            ## get indexes and values for four nearest pixels

            if lon <= lons[0] or lon >= lons[-1]: # edge cases
                i_lon_left = len(lons)-1
                i_lon_right = 0
                lon_left = lons[i_lon_left]
                lon_right = lons[i_lon_right]
            else: # everything else
                for i in range(len(lons)):
                    if lon < lons[i]:
                        i_lon_left = i-1
                        i_lon_right = i
                        lon_left = lons[i_lon_left]
                        lon_right = lons[i_lon_right]
                        break

            if lat <= lats[0] or lat >= lats[-1]: # edge cases
                i_lat_bottom = len(lats)-1
                i_lat_top = 0
                lat_bottom = lats[i_lat_bottom]
                lat_top = lats[i_lat_top]
            else: # everything else
                for i in range(len(lats)):
                    if lat < lats[i]:
                        i_lat_bottom = i-1
                        i_lat_top = i
                        lat_bottom = lats[i_lat_bottom]
                        lat_top = lats[i_lat_top]
                        break


            top_left = self.data[i_lat_top][i_lon_left][elementname]
            top_right = self.data[i_lat_top][i_lon_right][elementname]
            bottom_left = self.data[i_lat_bottom][i_lon_left][elementname]
            bottom_right = self.data[i_lat_bottom][i_lon_right][elementname]
            
            
            ## IMPORTANT -- (handling locations where GRS data is undefined) if atleast two of the nearest pixels are unresolved by GRS, just return the nanval. 
            searchable = (top_left, top_right, bottom_left, bottom_right)
            if (searchable.count(self.nanval) > 1):
                return self.nanval

            ## testing

            # print(f"{lat_bottom} {lon2clon(lon_left)} {bottom_left}")
            # print(f"{lat_bottom} {lon2clon(lon_right)} {bottom_right}")
            # print(f"{lat_top} {lon2clon(lon_left)} {top_left}")
            # print(f"{lat_top} {lon2clon(lon_right)} {top_right}")
            # print()
            # print(lon_left)
            # print(lon_right)
            # print(lat_bottom)
            # print(lat_top)

    #         ## dealing with negative/NaN values
    #         num_reals = 4
    #         avg = 0
    #         if top_left != -1:
    #             num_reals -= 1
    #             avg += top_left
    #         if top_right != -1:
    #             num_reals -= 1
    #             avg += top_right
    #         if bottom_left != -1:
    #             num_reals -= 1
    #             avg += bottom_left
    #         if bottom_right != -1:
    #             num_reals -= 1
    #             avg += bottom_right

    #         avg /= num_reals

            ## bilinear interpolation

            clon_left = lon2clon(lon_left)
            clon_right = lon2clon(lon_right)
            cola_bottom = lat2cola(lat_bottom)
            cola_top = lat2cola(lat_top)


            if abs(i_lon_right - i_lon_left) == 1: # somewhere in the middle
                londist = abs(lon_right-lon_left)
                leftdist = (lon-lon_left) / londist
                rightdist = (lon_right-lon) / londist
            else: # on the edges
                londist = abs(clon_right-clon_left)
                leftdist = (clon-clon_left) / londist
                rightdist = (clon_right-clon) / londist
            # print(londist)
            topinterp = top_left*(1-leftdist) + top_right*(1-rightdist)
            bottominterp = bottom_left*(1-leftdist) + bottom_right*(1-rightdist)


            if abs(i_lat_top - i_lat_bottom) == 1: # somewhere in the middle
                latdist = abs(lat_top-lat_bottom)
                bottomdist = (lat-lat_bottom) / latdist
                topdist = (lat_top-lat) / latdist
            else: # on the edges
                latdist = abs(cola_top-cola_bottom)
                bottomdist = (cola-cola_bottom) / latdist
                topdist = (cola_top-cola) / latdist    
            # print(latdist)

            finalinterp = topinterp*(1-topdist) + bottominterp*(1-bottomdist)

            if elementname == "th":
                # finalinterp *= 1e-6
                finalinterp *= 10**-6
            else:
                # finalinterp *= 1e-2
                finalinterp *= 10**-2

            return finalinterp

            # return [londist, latdist]
        
        
    def __getAdjustedConcentration(self, lon, lat, elementname):
        """
        Helper method for "getConcentration"
        
        "Groundwater production from geothermal heating on early Mars and implication for early martian habitability"
            Ojha et al. 2020
            https://www.science.org/doi/10.1126/sciadv.abb1669
            
        > For such measurement to represent the bulk chemistry of the martian upper crust, it must be normalized to 
        > a volatile-free basis (22). That equates to a 7 to 14% increase in the K, Th, and U abundances (22), which 
        > we applied to the chemical maps by renormalizing to Cl, stoichiometric H2O, and S-free basis.
        """
        
        init_conc = self.getConcentration(lon, lat, elementname, normalized=False)
        # if elementname == "th":
        #     init_conc *= 10e-4
        
        sum_volatile_conc = 0
        for volatile in ["cl", "h2o", "si"]:
            this_conc = self.getConcentration(lon,lat, volatile, normalized=False)
            
            ## IMPORTANT -- handling locations where GRS data is undefined
            if this_conc == self.nanval:
                return self.nanval
            
            
            
            # print(this_conc)
            if this_conc > 0:
                sum_volatile_conc += this_conc
        # print(sum_volatile_conc)
        # init_conc *= (1)/(1-(sum_volatile_conc/100))
        init_conc *= (1)/(1-(sum_volatile_conc))
        
        return init_conc
    
    
    
    
    def getNanVal(self):
        """
        Get value used for coordinates where GRS doesn't provide data.
        """
        return self.nanval

    
    
    
###########################
# General helper functions
    
def lon2clon(lon):
    return lon % 360
def clon2lon(clon):
    return ((clon-180) % 360) - 180

def lat2cola(lat):
    return lat % 180
def cola2lat(cola):
    return ((cola-90) % 180) - 90