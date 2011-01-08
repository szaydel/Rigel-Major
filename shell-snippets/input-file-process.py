#!/usr/bin/python3.1
#
#
#
#
#
import sys, os, fileinput
i = sys.argv[1:]
print ('input filename is', i)
f = fileinput.input(i)
for a in f:
        print(a)
