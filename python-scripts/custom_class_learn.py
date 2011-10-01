class CuErr(Exception):
    logfile = '/tmp/errlog'
    def __init__(self, ctime, ret_code, info):
        self.info = info
        self.ret_code = ret_code
        self.ctime = ctime
        
    def printerr(self):
        print '[%d] Return Code: %d We encountered <%s> error' \
              % (self.ctime, self.ret_code, self.info)
        
    def logerr(self):
        import sys
        # self.logfile = logfile
        x = open(self.logfile, 'a')
        print type(x)
        sys.stdout = x
        # msg = ' '.join([ str(x) for x in self.ctime, self.ret_code, self.info ])
        print '[%d] || Return Code: %d || Mesg: %s' \
              % (self.ctime, self.ret_code, self.info)

try:
    func()
except CuErr as e:
    e.printerr()
    e.logerr()

def func():
    import time
    time_now = time.mktime(time.localtime())
    raise CuErr(time_now, 100, 'Danger Will Robinson')