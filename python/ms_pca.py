from spectral import *

# open image with generic hdr file
img = envi.open('/Users/hb/phd/data/Database_Chaddad/all.hdr', '/Users/hb/phd/data/Database_Chaddad/Benign_Hyperplasia/10bph3.bsq')

# display image
view = imshow(img)

# only works with wxPython!
# view_cube(img)


# do PCA analysis
pc = principal_components(img)

print(pc.eigenvalues)
print(pc.eigenvectors)

# retain Top 5 eigenvalues
rpc = pc.reduce(num=5)

print(rpc.eigenvalues)
print(rpc.eigenvectors)

# transform image into 5D via PCA
rimg = rpc.transform(img)

imshow(rimg)


# try 3D for comparison
rpc3 = pc.reduce(num=3)
rimg3 = rpc3.transform(img)
imshow(rimg3)


# try 1D for comparison
rpc1 = pc.reduce(num=1)
rimg1 = rpc1.transform(img)
imshow(rimg1)