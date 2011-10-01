#! /usr/bin/env python

## Python Custom Error classes examples

class ErrorWithCode(Exception):
    def __init__(self, err_code):
        self.err_code = err_code
    def __str__(self):
        return repr(self.err_code)

b = None
try:
    if b is '':
        ''' Error code 1000 is raised when we are
         expecting some value in variable /b/
         but receive an empty string
        '''
        raise ErrorWithCode(1000)

    elif b is None:
        raise ErrorWithCode(1001)
    
except ErrorWithCode as e:
    print "Received error with code:", e.err_code