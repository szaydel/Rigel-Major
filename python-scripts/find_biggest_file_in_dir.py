#!/usr/bin/python3.1
import os, sys, getopt

biggest = ("", -1)
directory = sys.argv[1]
# directory = '/tmp'
os.chdir(directory)

print('Searching', directory)

def search(dir):
    global biggest
    for each_item in os.listdir(dir):
        ## each_item = os.path.join(os.curdir,each_each_item)
        each_item = os.path.join(os.curdir,each_item)
        ## each_item = dir + "/" + each_item
        if os.path.isdir(each_item):
            print(each_item, 'Is a Directory...')
            search(each_item)
        else:
            print(each_item, 'Is a File...')
            each_itemsize = os.path.getsize(each_item)
            print(biggest[1])
            if each_itemsize > biggest[1]:
                    biggest = (each_item, each_itemsize)

search(directory)
if biggest[1] >= -1:
    print ('Found: ', biggest)
    # Do something with biggest