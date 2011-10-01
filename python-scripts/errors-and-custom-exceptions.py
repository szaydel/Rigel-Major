#!/usr/bin/env python
## This is how we create a Custom Exception Class and raise Custom Exceptions

## We create a custom exception using base Exception built-in Class
class MyError(Exception):
    def __init__(self, value, err_code):
        self.value = value
        self.err_code = err_code
    def __str__(self):
        return repr((self.value, self.err_code))

a = ('my string', '')
try:
    if isinstance(a, str):
        raise MyError('Value is a string, should be <int>', 1001)
    elif isinstance(a, tuple):
         raise MyError('Value is a tuple, should be <int>', 1002)
except MyError as e:
    print 'Yo', e


## Defining Exception Hierarchy
class GeneralScsiErr(Exception): pass
class SpecificScsiErr_1(GeneralScsiErr): pass
class SpecificScsiErr_2(GeneralScsiErr): pass

def raiser_1():
    x = GeneralScsiErr()
    raise x

def raiser_2():
    x = SpecificScsiErr_1()
    raise x

def raiser_3():
    x = SpecificScsiErr_2()
    raise x

for func in (raiser_1, raiser_2, raiser_3):
    try:
        func()
    except GeneralScsiErr: # Match General or any subclass of it
        from sys import exc_info
        print('caught:', exc_info()[0])


try:
    with open('/tmp/myfile-1', 'rt') as f:
        f.readline()
except IOError as e:
    print "I/O error [{0}] {1}: {2}".format(e.errno, e.strerror, e.filename)