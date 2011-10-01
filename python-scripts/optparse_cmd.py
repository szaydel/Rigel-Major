#!/usr/bin/env python3.1
import os
import sys
import optparse

(myopts) = sys.argv[1:]
parser = optparse.OptionParser()
parser.add_option('-d','--decrypt',action='store_const',const='decr',dest='operation')
parser.add_option('-e','--encrypt',action='store_const',const='encr',dest='operation')
parser.add_option('-f','--file',action='store',type='string',dest='file_list')

opts,args = parser.parse_args()
print(opts,args)
print(opts.operation)
print(opts.file_list)