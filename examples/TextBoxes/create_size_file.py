#! /usr/bin/python

import os, sys
import glob
from PIL import Image

img_dir = "/home/ada/Documents/Textboxes/icdar2013/Challenge2_Test_Task12_Images"

img_lists = glob.glob(img_dir + '/*.jpg')

test_name_size = open('/home/ada/Documents/Textboxes/test_name_size.txt', 'a')

for item in img_lists:
    img = Image.open(item)
    width, height = img.size
    temp1, temp2 = os.path.splitext(os.path.basename(item))
    test_name_size.write(temp1 + ' ' + str(height) + ' ' + str(width) + '\n')