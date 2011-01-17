#!/usr/bin/python3.1
## For each file in a directory tree, create a full path
## and check the file using 'stat', to get information about
## use if, elif to return whether a file is a file or something
## else

import os, stat
my_path = '/tmp'
for dirpath, dirnames, filenames in os.walk(my_path):
    for f in dirnames or filenames:
        x = (os.path.join(dirpath,f))
        x_stat = os.stat(x) [stat.ST_MODE]
        if stat.S_ISREG(x_stat):
            print(x, 'is a Regular File: ')
        elif stat.S_ISDIR(x_stat):
            print(x, 'is a Directory: ')
        elif stat.S_IFIFO:
            print(x, 'is a sicket File: ')
