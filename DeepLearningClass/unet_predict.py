#!/usr/bin/env python

import os, sys, numpy
from PIL import Image

from model import unet
import process_data 
from options import parse_command_line_arguments
from keras.callbacks import ModelCheckpoint
from keras.optimizers import Adam

def visualize_results(file_path):
    img = Image.open(file_path)
    img.show()
    return

# -----------------------------------------------------------------

if __name__ == "__main__":

    # Parse command line arguments
    opt, sf = parse_command_line_arguments("predict")

    # Get data
    num_images = len(os.listdir(opt.data_folder + "/" + \
                                opt.data_type + "/train/image"))
    test_dir = os.path.join(opt.data_folder, opt.data_type, "test")
    testGene = process_data.testGenerator(test_dir, num_image=num_images)

    # Define a model
    model = unet(start_filters=sf, drop_rate=0.5)   
    model.compile(optimizer = Adam(lr = 1e-4), \
                  loss      = "binary_crossentropy", \
                  metrics   = ['accuracy'])

    # Run the model
    checkpoint_name = os.path.join('checkpoints', \
        ".".join([opt.in_prefix,opt.data_type,"h5"]))
    print("Input checkpoint_name=", checkpoint_name)
    model.load_weights(checkpoint_name)
    results = model.predict_generator(testGene, num_images, verbose=1)
    process_data.saveResult(test_dir, results)

