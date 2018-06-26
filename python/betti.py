import matplotlib.pyplot as plt

from skimage import data
from skimage.filters import threshold_otsu, threshold_adaptive

import scipy.ndimage as ndi
import scipy.misc as spm

from spectral import *

import math
from PIL import Image

import subprocess as sp

chomp_path = "/Users/hb/phd/code/chompfull_mac64/"
chomp = chomp_path + "bin/chomp"

def img2binary_img(img):
    """Turn multichannel image into binary multichannel image.

    Thresholds are calculated for each band with the otsu method.
    Returns a binary array with the same shape.
    """
    if(len(img.shape) > 2):
        # generate a threshold for every channel
        global_thresh = list(map(lambda x:
                                  threshold_otsu(img[:,:,x]),range(img.shape[2])))
    else:
        global_thresh = threshold_otsu(img)
    return img > global_thresh


def get_betti(binary_img):
    """Calculate the Betti numbers for a 2D binary image.

    Returns an array of Betti numbers or [0,0,0] for blank images"""
    arr = []
    path = "/Users/hb/Downloads/tmp.txt"
    for x in range(binary_img.shape[0]):
        for y in range(binary_img.shape[1]):
            if(not(binary_img[x,y])):
                arr.append([x,y])
    if(len(arr) > 0):
        np.savetxt(path,
                   np.array(arr, dtype="int"),
                   fmt='%d',
                   delimiter=' ',
                   newline='\n')
        out = sp.check_output([chomp, path])
        out = list(map(int, out.strip().split()))
    else:
        out = [0,0,0]
    return out


def get_tiled_betti(binary_img, steps=14):
    """Calculate Betti numbers for a 2D binary image in tiles.

    steps: number of regions per axis (e.g., steps=14 results in a 14x14 grid)."""
    img = binary_img
    W = img.shape[0]
    H = img.shape[1]
    x_steps = np.linspace(0,W,num=steps+1).round().astype(int)
    y_steps = np.linspace(0,H,num=steps+1).round().astype(int)
    tiled_betti = np.zeros(shape=[steps,steps,3],dtype="int")
    for x in range(0,steps):
        for y in range(0,steps):
            betti = get_betti(img[x_steps[x]:x_steps[x+1],
                                  y_steps[y]:y_steps[y+1]])
            print([x,y,x_steps[x],x_steps[x+1],y_steps[y],y_steps[y+1],betti])
            tiled_betti[x,y] = betti
    return tiled_betti


def bettishow(data,title=None):
    betti = data['betti'][:,:,1]
    imshow(data['img'],title=title)
    W = betti.shape[0]
    H = betti.shape[1]
    for x in range(W):
        for y in range(H):
            if(betti[x,y] > 0):
                plt.annotate(str(betti[x,y]),
                             xy=((x + 0.5)/W,
                                 1 - ((y + 0.5)/H)
                             ),
                             xycoords='axes fraction',
                             horizontalalignment='center', verticalalignment='center')
    plt.grid()
    plt.xticks(range(0,512,math.ceil(512/betti.shape[0])))
    plt.yticks(range(0,512,math.ceil(512/betti.shape[1])))
    plt.show()


def bettishow2(data,title=None):
    betti = data['betti'][:,:,1]
    #imshow(data['img'],title=title)
    W = betti.shape[0]
    H = betti.shape[1]
    for x in range(W):
        for y in range(H):
            if(betti[x,y] > 5):
                plt.Circle((0.5,0.5),radius=0.07, color='g')
                plt.annotate(str(betti[x,y]),
                             xy=((x + 0.5)/W,
                                 1 - ((y + 0.5)/H)
                             ),
                             xycoords='axes fraction',
                             horizontalalignment='center', verticalalignment='center')
    plt.grid()
    plt.xticks(range(0,512,math.ceil(512/betti.shape[0])))
    plt.yticks(range(0,512,math.ceil(512/betti.shape[1])))
    plt.show()




#bettishow2(globals.images[utils.imgs_per_group['ca'][0]])


