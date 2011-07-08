#!/usr/bin/env python
################################################################################
### Put something here #####
################################################################################
#: Title       : Generic script to do something
#: Date        : 2011-05-24
#: Rev. Date   : ##
#: Author      : Sam Zaydel
#: Version     : 0.1.0
#: Description : 
#:             : 
#: Options     : Using optparse, try -h argument to see all available options
#: Path to file: not-defined
##
from os import path
from os import walk
from os import environ
from os import system
from sys import argv

args = argv[1:]

def list_files(x):
    all_files = []
    for root, dirnames, filenames in walk(x):
        for file in filenames:
            fullpath = path.join(root, file)
            all_files.append(fullpath)
    return all_files

for a in args:
    b = list_files(a)
    print b