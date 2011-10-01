#!/usr/bin/python3.1

import sys, os, subprocess, fileinput
args = sys.argv[1:]
# files = fileinput.input(args)
# args.insert = ['/usr/bin/gpg', '-d']
print(args[0])

## This will iterate through lines in the file
# for a in fileinput.input():
    #s = ['/usr/bin/gpg', '-d', a]
    #crypt = subprocess.Popen(s)
for a in args: 
    s = ['/usr/bin/gpg', '-d', a]
    crypt = subprocess.Popen(s,bufsize=-1,shell=True)