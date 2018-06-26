import globals

def get_num_bands(img):
    if((img.__class__.__name__ == 'ndarray')
       | (img.__class__.__name__ == 'ImageArray')):
        return img.shape[2]
    else:
        return img.nbands

imgs = list(globals.images.keys())
imgs_per_group = {'bph':[],'pin':[],'ca':[]}
for group,_ in imgs_per_group.items():
    for val in imgs:
        if(val.find("10" + group) >= 0):
            imgs_per_group[group].append(val)
