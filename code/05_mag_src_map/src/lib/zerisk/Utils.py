import os



'''
--------------------------------------------------------------------------------------
System
--------------------------------------------------------------------------------------
'''


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
            `utils.getPath('current', '..', 'data', 'foo.txt')`            
    """
    args = [os.getcwd() if arg == 'current' else arg for arg in args]
    return os.path.abspath(os.path.join(*args))





def print_dict(d: dict, indent: int = 0) -> None:
    """
    DESCRIPTION:
    ------------
        Cleaner way to print a dictionary.

    PARAMETERS:
    ------------
        d : dict
        indent : int

    """
    for key, value in d.items():
        print('\t' * indent + str(key))
        if isinstance(value, dict):
            print_dict(value, indent+1)
        else:
            print('\t' * (indent+1) + str(value))
    return








'''
--------------------------------------------------------------------------------------
Coordinates
--------------------------------------------------------------------------------------
'''


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










# '''
# --------------------------------------------------------------------------------------
# Numpy arange
#     Source: https://stackoverflow.com/a/57321916
# --------------------------------------------------------------------------------------
# '''


# import numpy as np

# def np_arange_cust(
#         *args, rtol: float=1e-05, atol: float=1e-08, include_start: bool=True, include_stop: bool = False, **kwargs
# ):
#     """
#     Combines numpy.arange and numpy.isclose to mimic open, half-open and closed intervals.

#     Avoids also floating point rounding errors as with
#     >>> np.arange(1, 1.3, 0.1)
#     array([1., 1.1, 1.2, 1.3])

#     Parameters
#     ----------
#     *args : float
#         passed to np.arange
#     rtol : float
#         if last element of array is within this relative tolerance to stop and include[0]==False, it is skipped
#     atol : float
#         if last element of array is within this relative tolerance to stop and include[1]==False, it is skipped
#     include_start: bool
#         if first element is included in the returned array
#     include_stop: bool
#         if last elements are included in the returned array if stop equals last element
#     kwargs :
#         passed to np.arange

#     Returns
#     -------
#     np.ndarray :
#         as np.arange but eventually with first and last element stripped/added
#     """
#     # process arguments
#     if len(args) == 1:
#         start = 0
#         stop = args[0]
#         step = 1
#     elif len(args) == 2:
#         start, stop = args
#         step = 1
#     else:
#         assert len(args) == 3
#         start, stop, step = tuple(args)

#     arr = np.arange(start, stop, step, **kwargs)
#     if not include_start:
#         arr = np.delete(arr, 0)

#     if include_stop:
#         if np.isclose(arr[-1] + step, stop, rtol=rtol, atol=atol):
#             arr = np.c_[arr, arr[-1] + step]
#     else:
#         if np.isclose(arr[-1], stop, rtol=rtol, atol=atol):
#             arr = np.delete(arr, -1)
#     return arr

# def np_arange_closed(*args, **kwargs):
#     return np_arange_cust(*args, **kwargs, include_start=True, include_stop=True)

# def np_arange_open(*args, **kwargs):
#     return np_arange_cust(*args, **kwargs, include_start=True, include_stop=False)