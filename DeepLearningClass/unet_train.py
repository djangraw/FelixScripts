#!/usr/bin/env python

import os, sys, re, argparse

import tensorflow as tf

from keras.optimizers import Adam
from keras.callbacks import Callback, ModelCheckpoint
#from keras.utils import multi_gpu_model
from keras.utils.multi_gpu_utils import multi_gpu_model

from model import unet
import process_data
from options import parse_command_line_arguments

def get_orig_data_size(train_path):
    return len(os.listdir(os.path.join(train_path, "image")))

# -----------------------------------------------------------------------------

if __name__ == "__main__":

    # Parse command line options
    opt, data_gen_args, checkpoint_name, input_weights_file, sf = \
        parse_command_line_arguments("train")
  
    os.environ['CUDA_VISIBLE_DEVICES'] = "0,1,2,3"
 
    # Get training data 
    input_data_dir = os.path.join(opt.data_folder, opt.data_type, "train")
    orig_data_size = get_orig_data_size(input_data_dir)
    training_data_generator = \
        process_data.trainGenerator(opt.batch_size*opt.num_gpus, input_data_dir, \
                            'image', 'label', data_gen_args, \
                            save_to_dir = None)

    # Define a model
    if opt.num_gpus > 1:
        with tf.device('/cpu:0'):
            model = unet(summary = opt.summary, start_filters=sf, drop_rate=0.5,\
                         pretrained_weights=input_weights_file) 
        model = multi_gpu_model(model, gpus=opt.num_gpus)
    else:
        model = unet(summary = opt.summary, start_filters=sf, drop_rate=0.5,\
                     pretrained_weights=input_weights_file)
    model.compile(loss      = "binary_crossentropy", \
                  optimizer = Adam(lr = opt.learning_rate), \
                  metrics   = ['accuracy'])

    # Run the model
    callback = ModelCheckpoint(filepath=checkpoint_name, \
                               verbose=opt.verbose, save_weights_only=True)
    model.fit_generator(training_data_generator, epochs=opt.num_epochs,\
                        steps_per_epoch=(orig_data_size*opt.aug_rate) // \
                                        (opt.batch_size*opt.num_gpus),\
                        callbacks=[callback], workers=opt.num_gpus)               
