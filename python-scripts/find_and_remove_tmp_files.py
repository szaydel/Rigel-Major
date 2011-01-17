#!/usr/bin/python3.1

import os, os.path, re
myexp = re.compile('\.(sw.{0,1}p|t.{0,1}mp|~$)',re.IGNORECASE)

file_list = []
input_dir = '/tmp'

for root, dirs, files in os.walk(input_dir):
    for f in files:
        d = os.path.join(root,f)
        if myexp.search(d):
            if os.access(d,os.W_OK):
                os.remove(d)
            else:
                print('You do not have rights to remove', d)