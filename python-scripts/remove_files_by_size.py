#!/usr/bin/python3.1
## Set a specific filesize and remove
## all files that are larger

import os
target_size = 63

for dirpath, dirnames, filenames in os.walk('/tmp'):
    for file in filenames: 
        path = os.path.join(dirpath,file)
        print(path)
        if os.path.getsize(path) == target_size:
            print(file, 'is larger than', target_size, '\n')
            # os.remove(path)
        else:
            print(file, 'is not larger than', target_size, '\n')