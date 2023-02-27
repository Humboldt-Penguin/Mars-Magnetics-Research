import matplotlib
matplotlib.use('TkAgg')

import sys
sys.path.append("..")

from model.GRS import GRS as grs

GRS = grs()
GRS.loadData()
GRS.visualize('th')
