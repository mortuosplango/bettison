globals.images[utils.imgs_per_group['bph'][0]].keys()

bph = globals.images[utils.imgs_per_group['bph'][0]]['img']
ca = globals.images[utils.imgs_per_group['ca'][0]]['img']


globals.images

globals.images
##

np.linspace(0,512,8)


for x,y in zip(range(bph.shape[0]), range(bph.shape[1])): print(x,y)

##

binary_img = np.zeros(shape=[img.width,img.height],dtype="bool")
for x in range(img.width):
    for y in range(img.height):
        binary_img[x,y] = (img.getpixel((x,y)) > 0)
get_betti(binary_img)

a = get_betti(binary_global[:,:,8])

b = get_tiled_betti(img2binary_img(ca)[:,:,8])

fig = plt.figure()
fig.imshow(b)

imshow(tiled_betti[:,:,1])
imshow(binary_global[:,:,15])

p = imshow(ca)

img = globals.images[utils.imgs_per_group['ca'][1]]


print(globals.images[utils.imgs_per_group['ca'][2]])



utils.imgs_per_group.keys()
bettishow(globals.images[utils.imgs_per_group['ca'][2]])
bettishow(globals.images[utils.imgs_per_group['bph'][4]])
bettishow(globals.images[utils.imgs_per_group['pin'][6]])

val = globals.images[utils.imgs_per_group['ca'][5]]
imshow(img2binary_img(val['img'])[:,:,8])

binval = img2binary_img(val['img'])
bettis = []
for i in range(binval.shape[2]):
    bettis.append(get_betti(binval[:14,:14,i]))

bettis

spect.imshow16(img2binary_img(val['img'])[:,:,:])


imshow(globals.images[utils.imgs_per_group['ca'][1]]['betti'][:,:,1])

b2 = get_tiled_betti(img2binary_img(val['img'])[:,:,8])
val = globals.images[utils.imgs_per_group['ca'][5]]
b2 = get_tiled_betti(img2binary_img(val['img'])[:,:,8],steps=7)

val3 = globals.images[utils.imgs_per_group['pin'][5]]
b3 = get_tiled_betti(img2binary_img(val3['img'])[:,:,8],steps=7)

val4 = globals.images[utils.imgs_per_group['bph'][5]]
b4 = get_tiled_betti(img2binary_img(val4['img'])[:,:,8],steps=7)

bettishow(dict(betti=b,img=val['img']))
bettishow(dict(betti=b2,img=val['img']))
bettishow(dict(betti=b3,img=val3['img']))
bettishow(dict(betti=b4,img=val4['img']))

img4 = spect.open_chaddad_image(utils.imgs_per_group['bph'][5])
pcv4 = spect.pc_reduce_img(img4, spect.do_pca(img4))

imshow(pcv4[:,:,0])

lpcv4 = pcv4.load()
lpcv4[:,:,0]

def img2betti(path,steps=7):
    img = spect.open_chaddad_image(path)
    pcv = spect.pc_reduce_img(img, spect.do_pca(img)).load()
    return get_tiled_betti(img2binary_img(pcv)[:,:,0],steps=steps)


b2a = img2betti(utils.imgs_per_group['ca'][5])
bettishow(dict(betti=b2a,img=val['img']))

b3a = img2betti(utils.imgs_per_group['pin'][5])
bettishow(dict(betti=b3a,img=val3['img']))

imshow(img2binary_img(lpcv4)[:,:,1])
imshow(img2binary_img(val4['img'])[:,:,1])
imshow(lpcv4[:,:,0])


spect.imshow5(lpcv4)
spect.imshow5(img2binary_img(lpcv4))

spect.imshow16(img2binary_img(val4['img']))

b5 = get_tiled_betti(img2binary_img(lpcv4)[:,:,0],steps=7)
bettishow(dict(betti=b5,img=val4['img']))

dict(a=12)

sim.SimplicalComplex

importlib.reload(sim)


bph[]
globals.images[utils.imgs_per_group['bph'][0]].keys()


spect.imshow_grid(globals.images[utils.imgs_per_group['bph'][0]]['winpca'],2,5)





e1 = [(0, 1), (1, 2), (2, 0)]
sc1 = sim.SimplicialComplex(e1)

sc1.betti_number(1)


globals.images[last_path]['betti'][0,0]

c = get_betti(img2binary_img(globals.images[last_path]['pca'][:73,:73,0]))
b = get_tiled_betti(img2binary_img(globals.images[last_path]['pca'][:73,:73,0]), steps=1)
b == c


b = get_tiled_betti(img2binary_img(globals.images[last_path]['pca'][:,:,0]), steps=7)

np.linspace(0,512,8).round()

b[6,6]
b[0,6]

bettishow(globals.images[last_path])

print(globals.images[last_path]['betti'])

np.ndarray.tofile
imshow(globals.images[last_path]['img'][:73,:73])

imshow(globals.images[last_path]['pca'][:73,:73,0])


binary_global = bph > global_threshs

spect.imshow16(img2binary_img(bph))

spect.imshow16(binary_g)

# don't want binary_adaptive as images should be well-lit and not needing it
# probably removes information
# block_size = 40
# binary_adaptive = threshold_adaptive(image[:,:,8], block_size, offset=10)


img = Image.open("/Users/hb/Downloads/bw_image.bmp")
arr = []
for x in range(img.width):
    for y in range(img.height):
        if(img.getpixel((x,y)) < 255):
            arr.append([x,y])
np.savetxt("/Users/hb/Downloads/bw_img.txt",
           np.array(arr).astype(int),
           fmt='%d',
           delimiter=' ',
           newline='\n')
sp.check_output([chomp, "/Users/hb/Downloads/bw_img.txt"])


# do it for all images
for key,val in globals.images.items():
    print(key)
    if not 'pca' in globals.images[key]:
        img = spect.open_chaddad_image(key)
        pca = spect.pc_reduce_img(img, spect.do_pca(img)).load()
        globals.images[key]['pca'] = pca
        globals.images[key]['betti'] = get_tiled_betti(img2binary_img(pca[:,:,0]) == False, steps=7)
    bettishow(globals.images[key],title=key)





img = Image.open("/Users/hb/Downloads/bw_image.bmp")
arr = []
for x in range(img.width):
    for y in range(img.height):
        if(img.getpixel((x,y)) < 255):
            arr.append((x,y))

sc = sim.SimplicialComplex(arr)
sc.betti_number(1)

import simcomplex.abssimcomplex as sim
import simcomplex.vrcomplex as vrc
def get_betti2(binary_img):
    """Calculate the Betti numbers for a 2D binary image.

    Returns an array of Betti numbers or [0,0,0] for blank images"""
    arr = []
    path = "/Users/hb/Downloads/tmp.txt"
    for x in range(binary_img.shape[0]):
        for y in range(binary_img.shape[1]):
            if(not(binary_img[x,y])):
                arr.append((x,y))
    if(len(arr) > 0):
        sc = vrc.VietorisRipsComplex(arr,1)
        out = list(map(sc1.betti_number, range(3)))
    else:
        out = [0,0,0]
    return out

binary_img = np.zeros(shape=[img.width,img.height],dtype="bool")
for x in range(img.width):
    for y in range(img.height):
        binary_img[x,y] = (img.getpixel((x,y)) > 0)

get_betti(binary_img) == get_tiled_betti(binary_img,steps=1)

get_betti2(binary_img)


import PIL.ImageOps
img = Image.open("/Users/hb/Downloads/1746-1596-8-S1-S27-2-l.jpg")
gimg = PIL.ImageOps.grayscale(img)
arr = np.zeros(shape=[img.width,img.height,3],dtype="int")
for x in range(img.width):
    for y in range(img.height):
        arr[x,y] = img.getpixel((x,y))

bimg = img2binary_img(arr)

imshow(bimg[:,:,0])

garr = np.zeros(shape=[gimg.width,gimg.height],dtype="int")
for x in range(gimg.width):
    for y in range(gimg.height):
        garr[x,y] = gimg.getpixel((x,y))



img
gimg.getpixel((0,0))
imshow(garr)


pimg = PIL.ImageOps.posterize(gimg,1)

# don't want binary_adaptive as images should be well-lit and not needing it
# probably removes information
block_size = 40
binary_adaptive = threshold_adaptive(garr, block_size, offset=10)

imshow(binary_adaptive)

bimg2 = img2binary_img(garr)

len(garr.shape)

imshow(bimg)
imshow(bimg2)

import betti

betti.bettishow(globals.images[utils.imgs_per_group['ca'][0]])

betti.bettishow(list(globals.images.values())[1])



def get_betti3(binary_img):
    """Calculate the Betti numbers for a 2D binary image with the new chomp implementation.

    Returns an array of Betti numbers or [0,0,0] for blank images"""
    arr = []
    path = "/Users/hb/Downloads/tmp.txt"
    for x in range(binary_img.shape[0]):
        for y in range(binary_img.shape[1]):
            if(not(binary_img[x,y])):
                arr.append([x,y])
    if(len(arr) > 0):
        np.savetxt(path,
                   np.array(arr).astype(int),
                   fmt='(%d, %d)',
                   delimiter=', ',
                   newline='\n')
        out = sp.check_output(["chomp_cubical", path])
        out = list(map(int, out.strip().split()))
    else:
        out = [0,0,0]
    return out
