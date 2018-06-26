import os


def list_all_bsq_files_in_dir(directory = globals.datapath + "/Carcinoma"):
    for file in os.listdir(directory):
        if file.endswith(".bsq"):
            print(file)

def load_all_bsq_files(dir = globals.datapath):
    for (dirpath, dirnames, filenames) in os.walk(dir):
        for subdir in dirnames:
            for file in os.listdir(dirpath + subdir):
                if file.endswith(".bsq"):
                    print("Loading file " + file)
                    impath = dirpath + subdir + "/" + file
                    mem_load_image(impath)

load_all_bsq_files()

for key, val in globals.images.items():
    globals.images[key]['hl'] = hl.ms_compute_hl(val['img'], return_mean = True)

## calculate windowed haralick's features and PCA it
## CAUTION: takes a LONG time (ca. 20 mins per image)
for key, val in globals.images.items():
    if not 'winpca' in globals.images[key]:
        print(key)
        winhl = %time hl.win_hl_for_img(val['img'])
        #winpca = %time winhl2winpca(winhl)
        globals.images[key]['winhl'] = winhl
        #globals.images[key]['winpca'] = winpca


# remove non-mean haralick's features
# (not necessary at this time and take up space)
for key, val in globals.images.items():
    if 'hlk' in globals.images[key]:
        print("removing from ", key)
        globals.images[key].pop('hlk', None)


## remove old keys referencing ownCloud folder
for key, val in globals.images.items():
    print(key)
    if (key.find("ownCloud") >= 0):
        print("removing ", key)
        globals.images.pop(key, None)
