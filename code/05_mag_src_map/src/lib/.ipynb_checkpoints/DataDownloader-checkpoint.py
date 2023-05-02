"""
Written by Zain Eris Kamal (zain.eris.kamal@rutgers.edu).
Full repository available here: https://github.com/Humboldt-Penguin/Mars-Magnetics-Research
"""

import os
import gdown
import zipfile
import shutil

from lib.Utils import Utils as utils

class DataDownloader:
    
    
    def download_latest(path__datahome: str, data_name: str, url: str, overwrite: bool = False, verbose: bool = False) -> None:
        """
        DESCRIPTION:
        ------------
            - Given a Google Drive folder containing a single zip file of data -- download, extract, and delete the zipfile.
            - Best practice: Structure Google Drive data folders like this:
                .
                └── 230430_data/ ---------------------------- overarching folder; set "anyone with the link can view" so it filters down to all children. 
                    ├── GRS/ -------------------------------- hard link this in data README. 
                    │   ├── latest/ ------------------------- hard link this in module/class that interfaces with dataset (which is then passed to this function as `url`). if you ever update a dataset, simply drag outdated version from "latest/" to parent folder, and upload new zipfile to "latest/"; the hardlink to "latest/" ensures we get whatever's in that folder, i.e. the most up-to-date version.
                    │   │   └── GRS_v3.zip ------------------ zipfile of dataset; note that zipfilename is "GRS_v3.zip", but unzipped version is just "GRS/". 
                    │   ├── GRS_v1.zip ---------------------- older version of dataset, kept for records.
                    │   └── GRS_v2.zip
                    ├── crustal_thickness/
                    │   ├── latest/
                    │   │   └── crustal_thickness_v2.zip
                    │   └── crustal_thickness_v1.zip
                    └── ...
        
        
        PARAMETERS:
        ------------
            path__datahome : str
                Full path to directory where we want the data we're downloading to reside.
            data_name : str
                Name of dataset folder (i.e. what is produced when dataset is unzipped) -- used to check if dataset has already been downloaded.
            url : string
                Link to a Google Drive folder which contains a single zipfile.
            overwrite : bool
                If true and data already exists in `path__datahome`, existing data will be replaced. Else no action taken.
        """
        
        path__datahome_data = utils.getPath(path__datahome, data_name)
        
        
        
        if (os.path.exists(path__datahome_data) and not overwrite):
            if verbose:
                print(f'Data folder already exists at \n{path__datahome_data}. \nTo overwrite, add `overwrite=True` param.\n')
        else: # data folder does NOT exist
            
            if overwrite:
                shutil.rmtree(path__datahome_data)
                
            # download + unzip
            downloaded_file = gdown.download_folder(url=url, output=path__datahome, quiet=True, use_cookies=False)
            downloaded_file = utils.getPath(downloaded_file[0])
            
            if downloaded_file.endswith('.zip'):
                with zipfile.ZipFile(downloaded_file, 'r') as zip_ref:
                    zip_ref.extractall(path__datahome)
                os.remove(downloaded_file)
                
            if verbose:
                print(f'Downloaded to \n{path__datahome_data}\n')
        

                    
        # if verbose:
        #     print("Data folder contents: \n\t", end='')
        #     print(*os.listdir(path__datahome_data), sep='\n\t')
        
        
        return