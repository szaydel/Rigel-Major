#!/usr/bin/python3.1
## Determine filesize and return whether or not
## file is larger or smaller than watermark

import os

for i in myflist:
    x = int(os.path.getsize(i))
    if x > 6000000:
        print(i, 'is larger than 6MB')
    else:
        print(i, 'is not larger than 6MB')