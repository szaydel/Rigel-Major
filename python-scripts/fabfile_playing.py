#!/usr/bin/env python
from fabric.api import *
import os

@hosts('server03')
def simple_put():
    file = prompt('Enter path information:')
    if os.access(file,os.R_OK):    
        put(local_path=file, remote_path='/tmp/foo')
    else:
        print 'File is not accessible...'

def demo():
    