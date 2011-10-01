#!/usr/bin/env python

## Meaningful Exception class used together with subprocess
## as a way to validate expected return code, and if failed
## raise an exception, handle it, as well as retun useful
## troubleshooting information

class CuErr(Exception):
   
    def _ctime():
        import time
        x = time.mktime(time.localtime())
        return x

    ## initialize instance and enable a number of variables
    ## that we should expect to receive from the 
    ## raise CuErr(la...la...la) statement

    def __init__(self, cmd, msg, ret_code):
        time_now = _ctime() ## Generate current time
        self.cmd = cmd
        self.msg = msg
        self.ret_code = ret_code
        self.time_now = time_now

    ## sys.exc_info() will give us some details
    def err_details(self):
        import sys
        return (self.cmd, self.msg, self.ret_code, self.time_now, sys.exc_info()[0])
    
mycmd = ['ls','-l','/tmp/foo.f']
try:
    stdo= subprocess.PIPE
    stde = subprocess.PIPE
    proc = subprocess.Popen(mycmd, stdout=stdo, stderr=stde)
    ret_code = proc.wait()
    if not ret_code == 0:
        raise CuErr('Unexpected Result!', proc.communicate(), ret_code)
    else:
        print 'Looks good here...'
    
except CuErr as e:
    print 'Msg: %s\nCmd: %s\nReturn Code: %s\nTimestamp: %s' \
          % (e.err_details()[0],\
            e.err_details()[1], e.err_details()[2],\
             e.err_details()[3])



## Example of inheriting from a class
class ComstarErr(GenSCSIErr):
    import time
    time_now = time.mktime(time.localtime())

    def __init__(self,devid,error):
        #self.time_now = _ctime() ## Generate current time
        self.devid = devid
        self.error = error

    def _ctime(self):
        self.time_now = time_now
        
    ## sys.exc_info() will give us some details
    def err_details(self):
        import sys
        print 'Timestamp: %d Device Id: %d Error: %s %s' % (self.time_now, self.devid, self.error, sys.exc_info()[0])
        # return (self.time_now, self.devid, self.error, sys.exc_info()[0])

class GenScsiErr(Exception):
    import time
    time_now = time.mktime(time.localtime())
        
    def __init__(self,devid,rc):
        self.devid = devid
        self.rc = rc
        
    def more_info(self):        
        if self.rc <= 100:
            self.det = 'Device does not respond'
        elif self.rc > 100:
            self.det = 'Device does not exist'
        
        import sys
        print 'Timestamp: %d Device Id: %d Error: %s %s' % \
              (self.time_now, self.devid, self.det, sys.exc_info()[0])

## Usage of above Exception:
try:
    raise GenScsiErr(12345, 101)
except GenScsiErr as e:
    e.more_info()

class TestC(ComstarErr):
    def __init__(self,level,devid,error):
        ComstarErr.__init__(self,devid,error)
        self.level = level
        
    def fmtd_devid(self):
        zero_padded = str(self.devid).zfill(20)
        self.format = zero_padded
        print self.format, self.error, self.level