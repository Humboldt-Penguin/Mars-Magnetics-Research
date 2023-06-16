"""
Created by Zain Eris Kamal (zain.eris.kamal@rutgers.edu) on 06/15/23.
https://github.com/Humboldt-Penguin/Mars-Magnetics-Research/tree/main/code

Purpose: Automatically generate and reduce many crustal thickness models made by Mark Weiczorek's ["InSight Crustal Thickness Archive"](https://zenodo.org/record/6477509).

If you want to change the parameters for datasets generated, go to the section titled "run `make-grids.py` with various inputs".
"""



import subprocess
import os
import shutil
from datetime import datetime, timedelta
import logging

import numpy as np







''' helper functions '''


# copied from my zerisk.Utils module
def getPath(*args):
    """
    DESCRIPTION:
    ------------
        Join all arguments into a single path specific to your system. 
            - Use 'current' to get the directory this file (the one calling this function) is in. 
            - Use '..' to get the path to parent directory. 

    USAGE:
    ------------
        Example: If you're running a script/notebook in `/src/main/`, you can get the path to `/src/data/foo.txt` with:
            `getPath('current', '..', 'data', 'foo.txt')`            
    """
    args = [os.getcwd() if arg == 'current' else arg for arg in args]
    return os.path.abspath(os.path.join(*args))











''' pre-make all directories and create logger + log file '''

start_datetime = datetime.now()
checkpoint = datetime.now()

dir_grids = getPath('current', 'grids/')
dir_grids_generated = getPath(dir_grids, f'generated_{start_datetime.strftime("%d%m%y-%H%M")}')
dir_grids_generated_reduced = getPath(dir_grids_generated, 'reduced')

if os.path.exists(dir_grids_generated):
    shutil.rmtree(dir_grids_generated)
os.makedirs(dir_grids_generated, exist_ok=True)
os.makedirs(dir_grids_generated_reduced, exist_ok=True)

log_path = getPath(dir_grids_generated_reduced, 'log.txt')

# if os.path.isfile(log_path):
#     os.remove(log_path)

logging.basicConfig(
    level=logging.INFO,
    format="%(message)s", # format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),  # Output to console
        logging.FileHandler(log_path)  # Output to log file
    ]
)

logging.info(f'Running `crthick_reducer.py`.')
logging.info('')
logging.info(f'Saving logs to {log_path}')
logging.info('')
logging.info(f'Started running at {start_datetime.strftime("%m/%d/%Y %H:%M")}')
logging.info('------------------------------------------------------------------------------------------')
logging.info('')







''' run `make-grids.py` with various inputs and move/delete thickness/moho datasets '''



## generate inputs 

meta_args = []


# real inputs
for ref_int_model in range(16):
    for rho_south in [2900, 2850, 2800, 2750]:
        args = [ref_int_model, 30, 2900, rho_south, 0.1, 2]
        meta_args.append(args)


# # dummy inputs (all should fail to generate)
# for ref_int_model in [14,15,16]:
#     for rho_south in [2900, 2850]:
#         args = [ref_int_model, 30, 2900, rho_south, 0.1, 2]
#         meta_args.append(args)


# # dummy inputs (only 2 valid models)
# for ref_int_model in [14,15,16]:
#     for rho_south in [2900, 2850]:
#         args = [ref_int_model, 30, 2900, rho_south, 0.1, 2]
#         meta_args.append(args)


## automate python script execution for all inputs

logging.info(f'Running make-grids.py for {len(meta_args)} models...')

makegrids_path = getPath('current', 'make-grids.py')

num_generated = 0
num_failed = 0

for args in meta_args:

    mini_checkpoint = datetime.now()

    with open(os.devnull, "w") as devnull:
        process = subprocess.Popen(["python", makegrids_path], stdin=subprocess.PIPE, stdout=devnull, stderr=devnull)

    for arg in args:
        process.stdin.write(str(arg).encode() + b'\n')
        process.stdin.flush()

    process.stdin.close()

    escape = process.wait()

    mini_delta = datetime.now()-mini_checkpoint
    logging.info(f"     {num_generated+num_failed+1}. {'Succeeded' if escape==0 else '     Failed'} to generate with inputs {args} \t\t (this model took: {str(mini_delta).split('.')[0]}) ")



    if escape == 0: # successfully generated
        num_generated += 1

        for filename in os.listdir(dir_grids):    
            
            file_path = os.path.join(dir_grids, filename)

            if os.path.isfile(file_path):
                last_modified_time = datetime.fromtimestamp(os.path.getmtime(file_path))
                if last_modified_time > start_datetime:
                    if 'Mars-thick' in filename:
                        shutil.move(file_path, os.path.join(dir_grids_generated, filename))
                    elif 'Mars-moho' in filename:
                        os.remove(file_path)

    else: # invalid inputs
        num_failed += 1




logging.info('')
logging.info('')


logging.info('Finished running make-grids.py for all inputs.')
logging.info(f'* {num_generated} datasets generated.')
logging.info(f'* {num_failed} datasets failed to generate (model parameters not compatible, this is okay).')

delta = datetime.now()-checkpoint
logging.info(f'\n(This process took: {str(delta).split(".")[0]})')
checkpoint = datetime.now()

logging.info('')
logging.info('...')
logging.info('')










''' reduce crustal thickness files '''


num_reduced = 0

for filename in os.listdir(dir_grids_generated):

    file_path = getPath(dir_grids_generated, filename)

    if os.path.isfile(file_path):

        dat = np.loadtxt(file_path, delimiter=',')
        dat = dat[:,2]

        new_filename = filename[ :filename.index('.xyz') ] + '__shortened__grid=0.1.npy' # transforms '*.xyz' into '*__shortened__grid=0.1.npy'

        np.save(
            file = getPath(dir_grids_generated_reduced, new_filename),
            arr = dat
        )

        num_reduced += 1

logging.info('Finished reducing datasets.')
logging.info(f'* {num_reduced} datasets saved.')

delta = datetime.now()-checkpoint
logging.info(f'\n(This process took: {str(delta).split(".")[0]})')
checkpoint = datetime.now()








''' sanity check '''

logging.info('')
logging.info('')
logging.info('------------------------------------------------------------------------------------------')
logging.info('Summary (sanity check):')
logging.info(f'* {num_generated} datasets generated.')
logging.info(f'* {num_reduced} datasets saved.')
logging.info(f'* {num_failed} datasets failed to generate (model parameters not compatible, this is okay).')

logging.info('')
if (num_generated==num_reduced):
    logging.info('All is well :> \t(according to num_generated==num_reduced)')
else:
    logging.info('Something went wrong :< \t(according to num_generated==num_reduced)')
logging.info('------------------------------------------------------------------------------------------')
logging.info('')



''' finish logging '''


end_datetime = datetime.now()
logging.info(f'Finished running at {end_datetime.strftime("%m/%d/%Y %H:%M")}')
delta = end_datetime-start_datetime
logging.info(f'(Total execution time: {str(delta).split(".")[0]})')
logging.info('')

logging.info(f'Data available at: {dir_grids_generated_reduced}')

logging.shutdown()