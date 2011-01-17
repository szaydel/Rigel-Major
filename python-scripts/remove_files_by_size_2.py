#!/usr/bin/python3.1
## Set a specific filesize and remove
## all files that are larger

import os, os.path

for root, dirs, files in os.walk(dir):
    for f in files:
        fullpath = os.path.join(root, f)
        if os.path.getsize(fullpath) < 200 * 1024:
            os.remove(fullpath)
            
            
            
import os
my_path = '/some/path'
for dirpath, dirnames, filenames in os.walk(my_path):
    for f in filenames:
        x = (os.path.join(dirpath,f))
        print(x, 'Is  %i bytes' % (os.path.getsize(x)))
        