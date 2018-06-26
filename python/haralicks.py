import mahotas as mh
import numpy as np
import matplotlib.mlab as mlab
from utils import *

def ms_compute_hl(image, return_mean = True):
    band_list = range(get_num_bands(image))
    return mlab.amap(
        lambda x: mh.features.haralick(
            image[:,:,x].astype(int),
            return_mean = return_mean),
        band_list)

def compute_hl(img):
    mh.features.haralick(img, return_mean = True)


def win_hl_for_img(img, winsize = 32, overlap = 0.25):
    hopsize = int(winsize * overlap)
    width = img.shape[0]
    height = img.shape[1]

    return mlab.amap(
        lambda x: mlab.amap(
                lambda y: ms_compute_hl(
                    img[(x):(x + winsize),(y):(y + winsize),:],
                    return_mean = True),
                range(0,height,hopsize)),
        range(0,width,hopsize))
