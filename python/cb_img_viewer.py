import matplotlib.pyplot as plt

##
def make_cb_viewer(rimgL):
    fig = plt.figure()

    ax = fig.add_subplot(1,1,1)
    ax.imshow(rimgL[:,:,1])
    return fig, ax

## make responders
def make_handler(img, action="clicked", id="undefined"):
    def fn(event):
        if(event.xdata):
            inside = True
        else:
            inside = False
        
        # print statements seem to be not good for OSC latency
        if debug:    
            print("Received mouse " + action + ":", id, "X:",event.xdata, "Y:", event.ydata, "Button:", event.button)
        send_osc("/mouse/" + action,id, sc_osc_target, event.xdata, event.ydata, inside, event.button)
    return fn

fig.canvas.mpl_disconnect(cid_onclick)
cid_onclick = fig.canvas.mpl_connect('button_press_event', make_handler(rimgL, "clicked", img.filename))

fig.canvas.mpl_disconnect(cid_onrelease)
cid_onrelease = fig.canvas.mpl_connect('button_release_event', make_handler(rimgL, "released",img.filename))

fig.canvas.mpl_disconnect(cid_onmove)
cid_onmove = fig.canvas.mpl_connect('motion_notify_event', make_handler(rimgL, "moved", img.filename))
