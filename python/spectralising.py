from spectral import *
import matplotlib.pyplot as plt
import numpy as np

##

def open_bsq_image(hdr_path,img_path):
    return envi.open(hdr_path, img_path)

def open_chaddad_image(img_path='/Users/hb/phd/data/Database_Chaddad/Benign_Hyperplasia/10bph3.bsq'):
    """open image with generic hdr file"""
    return open_bsq_image('/Users/hb/phd/data/Database_Chaddad/all.hdr', img_path)

def do_pca(img):
    """do pca on image"""
    return principal_components(img)    

def pc_reduce_img(img, pc, num=5):
    """reduce image to num principal components and return reduced image"""
    rpc = pc.reduce(num=num)
    return rpc.transform(img)

##

def imshow_grid(img, nrows, ncols, title=None, cmap=None):
    """show bands of an image in a grid"""
    fig, axes = plt.subplots(nrows=nrows,ncols=ncols)
    if title:
        fig.canvas.set_window_title(title)
    for [ax,band] in zip(axes.flatten(),range(axes.flatten().size)):
        if((img.__class__.__name__ == 'TransformedImage') | (img.__class__.__name__ == 'ndarray')):
            img_band = img[:,:,band]
        else:
            img_band = img.read_band(band)
        ax.imshow(img_band, cmap=cmap)
        ax.axis('off')
    return fig, axes
    

def imshow16(img, title=None, cmap=None):
    """show all bands of 16 band image as grid"""
    return imshow_grid(img, 4, 4, title=title, cmap=cmap)

def imshow5(img, title=None, cmap=None):
    """show all bands of reduced image"""
    return imshow_grid(img, 1, 5, title=title, cmap=cmap)
    
##
