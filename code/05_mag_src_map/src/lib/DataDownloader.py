import os
import gdown
import zipfile
import shutil

class DataDownloader:
    
    def download_folder(path_src, url, overwrite = False, verbose = True):
        """
        Downloads all files within a google drive folder to `path_src/data/`. Extracts and deletes any zipped files.
        
        PARAMETERS:
            path_src : string
                Full path to source directory.
            url : string
                Link to Google drive folder.
            overwrite : boolean
                If true and `path_src/data/` exists, it will be deleted and redownloaded. Else no action taken.
                
        """
        
        path_data = os.path.abspath(os.path.join(path_src, "data/"))
        
        
        if (os.path.exists(path_data) and not overwrite):
            print('Data folder already exists. To overwrite, add `overwrite=True` param.')
            print()
        else:
            

            if overwrite:
                # safety check before removing stuff
                if ('home' not in path_data):
                    yn = input("The provided `path_src` parameter doesn't contain \"home\". On Linux systems, this means you might be deleting important directories. If you proceed, `path_src/data/` will be deleted. Make sure you have provided the correct path. \nWould you like to proceed? [y/n] ")
                    print()
                    if yn != "y": 
                        return
                    
                shutil.rmtree(path_data)            
            
            
            _ = gdown.download_folder(url=url, output=path_data, quiet=True, use_cookies=False)

            for shortfile in (os.listdir(path_data)):
                fullfile = os.path.abspath(os.path.join(path_data, shortfile))
                if fullfile.endswith('.zip'):
                    with zipfile.ZipFile(fullfile, 'r') as zip_ref:
                        zip_ref.extractall(path_data)
                        os.remove(fullfile)
        

                    
        if verbose:
            print("Data folder contents: \n\t", end='')
            print(*os.listdir(path_data), sep='\n\t')
        
        return