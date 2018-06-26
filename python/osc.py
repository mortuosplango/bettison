## osc client target and helper function

import liblo, sys
import globals
# send all messages to port 57120 on the local machine

def make_osc_target(port=57120):
    try:
        return liblo.Address(port)
    except liblo.AddressError as err:
        print(err)
        sys.exit()

def send_osc(addr, osc_target,*args):
    msg = liblo.Message(addr)
    for arg in args:
        msg.add(arg)
    liblo.send(osc_target, msg)

def data_to_sc(data,label,imgpath):
    path = imgpath + "." + label + ".csv"
    print("Write ", label, " to file", path)

    data.tofile(path, ",")

    print("Notify SuperCollider")
    send_osc("/new_data", globals.sc_osc_target, label, imgpath, path, *data.shape)
