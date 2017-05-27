import fnmatch
import os

matches = []

with open("testtext.txt", "wb") as myfile:
    for root, dirnames, filenames in os.walk('data'):
        for filename in fnmatch.filter(filenames, '*.jpg'):
            myfile.write(os.path.join(root, filename)+'\n')

