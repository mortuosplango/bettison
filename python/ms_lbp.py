from skimage.feature import local_binary_pattern
import numpy as np
import osc
import globals

from utils import *
##
# settings for LBP
radius = 3
n_points = 8 * radius

METHOD = 'uniform'
#METHOD = 'default'

##

def lbp_on_band(band):
    return local_binary_pattern(rimg[:,:,band], n_points, radius, METHOD)

def mc_lbp(image, radius = radius, n_points = n_points, method = METHOD):
    band_list = range(get_num_bands(image))
    # do lbp on each band
    print("Doing LBP with method", METHOD, "and radius", radius)
    lbp = map(lambda x: local_binary_pattern(image[:,:,x], n_points, radius, METHOD), band_list)
    # convert to numpy array and change axis to match image shape
    lbp = np.rollaxis(np.asarray(list(lbp), dtype=np.int16), 0, start=3)
    print("... Done")
    return lbp

##

def lbp_to_sc(lbp,imgpath):
    # write lbp to file
    path = imgpath + ".csv"

    print("Write LBP to file", path)
    # delete file if it exists - otherwise .tofile appends its values?
    #try:
    #    os.remove(path)
    #except OSError:
    #    pass
    lbp.tofile(path, ",")
    # send osc msg to supercollider about file
    print("Notify SuperCollider")
    osc.send_osc("/new_lbp", globals.sc_osc_target, path, *lbp.shape)

