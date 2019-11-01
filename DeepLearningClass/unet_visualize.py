#! /usr/bin/env python

import sys, os
import numpy as np
import cv2
import skimage.transform as trans
from matplotlib import pyplot as plt
from matplotlib import colors
from options import parse_command_line_arguments

if __name__ == "__main__":

    opt = parse_command_line_arguments("visualize")
    image_id   = opt.image_id
    test_dir   = os.path.join(opt.data_folder, opt.data_type, "test")
    image_type = opt.image_type 

    if not image_type in [1,2,3, None]:
        sys.exit("Invalid image type specified")

    try:  
        if image_type == None: 
            img_gr    = np.array(cv2.imread(test_dir + "/%d.png"%image_id))
            img_bw    = np.array(cv2.imread(test_dir + "/%d_predict.png"%image_id))
            img_color = np.array(cv2.imread(test_dir + "/%d_predict_RGB.png"%image_id), dtype=np.uint8)
        elif image_type == 1:
            img       = np.array(cv2.imread(test_dir + "/%d.png"%image_id))
        elif image_type == 2:
            img       = np.array(cv2.imread(test_dir + "/%d_predict.png"%image_id))
        else:
            img       = np.array(cv2.imread(test_dir + \
                        "/%d_predict_RGB.png"%image_id), dtype=np.uint8)
    except:
        sys.exit("Missisng data in folder " + test_dir)

    if image_type == None:
        fig=plt.figure(figsize=(12, 4))
        images=[img_gr, img_bw, img_color]
        for i in range(3):
            fig.add_subplot(1, 3, i+1)
            plt.imshow(images[i])
            plt.axis('off')
        plt.show()
    else:
        fig=plt.figure(figsize=(7, 7))
        plt.imshow(img)
        plt.axis('off')
        plt.show()

