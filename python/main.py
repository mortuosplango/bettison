import sys

# add code path to path
sys.path.append("/Users/hb/phd/code/python/")

import importlib

from spectral import *

# import code
import spectralising as spect
import ms_lbp
import globals
import osc
import haralicks as hl
import numpy as np
import matplotlib.pyplot as plt
import save_reload
import liblo
import math
#import betti
globals.st = liblo.ServerThread(4567)
globals.sc_osc_target = osc.make_osc_target(57120)
#globals.sc_osc_target = osc.make_osc_target(57121)
globals.max_osc_target = osc.make_osc_target(7400)
globals.st.start()
print("Created Server Thread on Port", globals.st.port)

data_file = globals.datapath + "analysis.pkl"
# save_reload.save_images(data_file, globals.images)
globals.images = save_reload.reload_images(data_file)
print("Reloaded images")

import utils


#globals.images['/Users/hb/phd/data/Database_Chaddad/Intraepithelial_Neolplasia/10pin2.bsq']['img']

##
#save_rgb("/Users/hb/test.png",globals.images['/Users/hb/phd/data/Database_Chaddad/Intraepithelial_Neolplasia/10pin1.bsq']['img'].shape)

def send_img_to_max(img, imgpath):
    path = imgpath + '.png'
    #im = spect.open_chaddad_image(imgpath)
    save_rgb(path, img)
    osc.send_osc('/image', globals.max_osc_target, path)
    print("sent image to max")



def send_osc2(addr, osc_target,args):
    msg = liblo.Message(addr)
    for arg in args:
        msg.add(arg)
    liblo.send(osc_target, msg)



def get_image_dict1(path):
    img = spect.open_chaddad_image(path).load()
    pc = spect.do_pca(img)
    rimg = spect.pc_reduce_img(img, pc, num=5)
    rimgL = rimg
    lbp = ms_lbp.mc_lbp(rimg)
    return dict(img = img, 
                pc = pc, 
                rimg5 = rimg, 
                rimg5L = rimgL, 
                lbp = lbp)

def get_image_dict(path):
    img = spect.open_chaddad_image(path).load()
    #lbp = ms_lbp.mc_lbp(img)
    return dict(img = img, 
                #lbp = lbp
                )


def mem_load_image(path):
    if not path in globals.images:
        img = get_image_dict(path)
        globals.images[path] = img
        return img
    else:
        print("image already cached - not loading again")
        return globals.images[path]


last_path = ""
def osc_load_cb(path, args, types):
    print("osc_load_cb():")
    for a, t in zip(args, types):
        print("received argument %s of type %s" % (a, t))

    path = args[0].replace('/Users/hb/ownCloud/phd/ImageSonification/', '/Users/hb/phd/')
    global last_path
    last_path = path
    try:
        img = mem_load_image(path)
        #send_osc2('/img/hl', globals.sc_osc_target,
        #    prepare_sign_data(img, [0,1,3,8]))
        #ms_lbp.lbp_to_sc(img['lbp'], path)
                #send_osc2('/img/hl', globals.sc_osc_target,
        #    prepare_sign_data(img, [0,1,3,8]))

        #osc.data_to_sc(img['winhl'],'winhl',path)
        #osc.data_to_sc(img['winpca'],'pca',path)
        #osc.data_to_sc(img['img'],'raw',path)
        osc.data_to_sc(img['betti'],'betti',path)
        send_img_to_max(img['img'], path)
        #bettishow(img)
    except:
        print("Unexpected error:", sys.exc_info()[0])
        print("image not found: " + path)

globals.st.del_method('/load', None)
globals.st.add_method('/load', None, osc_load_cb)



