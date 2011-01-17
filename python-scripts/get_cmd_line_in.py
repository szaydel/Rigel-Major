#!/usr/bin/python3.1
import os, sys, getopt
file_list = sys.argv[1:]
## Method to test if file is writable
## os.access(os.path.join(os.curdir,'name_of_file'), os.W_OK)
# file_list = s.split()
for each_item in file_list:
    each_item = os.path.join(os.curdir,each_item)
    if not os.access(each_item,os.W_OK):
        print('Unable to write/remove file')
    else:
        print('Deleting File:',each_item)
    ## x = os.remove(each_item)
    ## Testing for read access
        if not os.access(each_item,os.F_OK):
            print('Successfully deleted file:',each_item)
    # print(os.path.dirname(each_item))

