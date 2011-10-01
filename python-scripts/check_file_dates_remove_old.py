#!/usr/bin/env python
## For a list of files generated with 'os.walk' compare timestamp
## of each file against current time, and if the difference is
## greater than 23 days, remove the file
## 
import os,time

t_now = time.mktime(time.localtime())
for dirpath, dirnames, filenames in os.walk('/tmp/pyd/', topdown=True):
    for fi in filenames:
        ## Establish full path of each file
        path = os.path.join(dirpath,fi)
        t_lastmod = os.stat(path).st_mtime
        t_delta = t_now - t_lastmod
        ## We need to convert from seconds to days
        if (t_delta / 3600 / 24) >= 23:
            try:
                os.remove(path)
            except:
                IOError
                print('Could not remove file:',path)