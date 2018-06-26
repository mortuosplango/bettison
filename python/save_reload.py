
# save resulting analysis to file
import pickle
import globals

def save_images(path, images):
    ###########################################################
    # Careful: DO YOU REALLY WANT TO OVERWRITE YOUR ANALYSIS? #
    ###########################################################
    afile = open(path, 'wb')
    # not possible bc of the images not being stored in memory
    # probably better to save analysis into separate dictionary
    pickle.dump(images, afile)
    afile.close()

#reload object from file
def reload_images(path):
    data_file = open(path, 'rb')
    images = pickle.load(data_file)
    data_file.close()
    return images
