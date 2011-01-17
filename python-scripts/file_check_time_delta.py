#!/usr/bin/python3.1
## Compare ctime of files against current time
## to determine whether or not a file should be
## removed or kept

import os,time

f = ['/tmp/mytmpfile1','/tmp/mytmpfile2']
for list_item in f:
    x = int(os.path.getctime(list_item))
    time_now = int(time.time())
    if time_now - x >= 120:
        print('File', list_item, 'should be removed.')
    else:
        print('File', list_item, 'is OK.')