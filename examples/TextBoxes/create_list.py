import argparse
import os
from random import shuffle
import shutil
import subprocess
import sys

HOMEDIR = os.path.expanduser("~")
CURDIR = os.path.dirname(os.path.realpath(__file__))

# If true, re-create all list files.
redo = True
# The root directory which holds all information of the dataset.
data_dir = "{}/Documents/Textboxes".format(HOMEDIR)
# The direcotry which contains the images.
parent_dir = "icdar2013"
img_ext = "jpg"
# The directory which contains the annotations.
anno_prefix = "gt"
anno_ext = "xml"

train_list_file = "{}/train.txt".format(CURDIR)
test_list_file = "{}/test.txt".format(CURDIR)

# Create training set.
# We follow Ross Girschick's split.
if redo or not os.path.exists(train_list_file):
    datasets = ["icdar2013"]
    imgdir = "Challenge2_Training_Task12_Images"
    anno_dir = "Challenge2_Training_Task1_GT_xml"
    img_files = []
    anno_files = []
    for dataset in datasets:
        imgset_file = "{}/{}.txt".format(data_dir, dataset)
        with open(imgset_file, "r") as f:
            for line in f.readlines():
                name = line.strip("\n")
                img_file = "{}/{}/{}.{}".format(parent_dir, imgdir, name, img_ext)
                assert os.path.exists("{}/{}".format(data_dir, img_file)), \
                        "{}/{} does not exist".format(data_dir, img_file)
                anno_file = "{}/{}/{}.{}".format(parent_dir, anno_dir,  name, anno_ext)
                assert os.path.exists("{}/{}".format(data_dir, anno_file)), \
                        "{}/{} does not exist".format(data_dir, anno_file)
                img_files.append(img_file)
                anno_files.append(anno_file)
    # Shuffle the images.
    idx = [i for i in xrange(len(img_files))]
    shuffle(idx)
    with open(train_list_file, "w") as f:
        for i in idx:
            f.write("{} {}\n".format(img_files[i], anno_files[i]))

if redo or not os.path.exists(train_list_file):
    datasets = ["icdar2013_val"]
    imgdir = "Challenge2_Test_Task12_Images"
    anno_dir = "Challenge2_Test_Task1_GT_xml"
    img_files = []
    anno_files = []
    for dataset in datasets:
        imgset_file = "{}/{}.txt".format(data_dir, dataset)
        with open(imgset_file, "r") as f:
            for line in f.readlines():
                name = line.strip("\n")
                img_file = "{}/{}/{}.{}".format(parent_dir, imgdir, name, img_ext)
                assert os.path.exists("{}/{}".format(data_dir, img_file)), \
                        "{}/{} does not exist".format(data_dir, img_file)
                anno_file = "{}/{}/{}.{}".format(parent_dir, anno_dir, name, anno_ext)
                assert os.path.exists("{}/{}".format(data_dir, anno_file)), \
                        "{}/{} does not exist".format(data_dir, anno_file)
                img_files.append(img_file)
                anno_files.append(anno_file)
    # Shuffle the images.
    idx = [i for i in xrange(len(img_files))]
    shuffle(idx)
    with open(test_list_file, "w") as f:
        for i in idx:
            f.write("{} {}\n".format(img_files[i], anno_files[i]))
