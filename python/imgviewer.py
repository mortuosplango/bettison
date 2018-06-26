#!/Applications/pyzo2015a/bin/python3
import matplotlib
matplotlib.use('Qt4Agg')
import sys
sys.path.append("/Users/hb/phd/code/python/")
import spectralising as spect

from spectral import imshow

if __name__ == '__main__':
    img = spect.open_chaddad_image(sys.argv[1])
    print(img)
    imshow(img)
    input()
