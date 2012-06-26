#!/usr/bin/env python
__author__ = 'Sam Zaydel'

import os
import re
import shlex
import subprocess
import sys
import time
from daemon import Daemon
exec_cmd = shlex.split('/racktop/fmd-snoop/fmd-snoop.sh')

## Set any environment variables here, for example:
## os.environ["RSYNC_RSH"] = 'ssh' ## We want to use 'ssh' as our remote shell

#def run_command(cmd):
#    print '%s' % ('Got this far...')
#    x = subprocess.Popen(cmd,\
#        stdout=subprocess.PIPE,stderr=subprocess.PIPE,\
#        bufsize=4096,shell=False)
#    return x.returncode

class MyDaemon(Daemon):
    def run(self):
        blacklist = '/racktop/fmd-snoop/fmd-blklist.log'
        while True:
            p = subprocess.Popen('/racktop/fmd-snoop/bin/fmd-collect.sh',
                shell=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
            self.stdout, self.stderr = p.communicate()

#            if self.stdout:
#                line = self.stdout.split()
#                f = open('/racktop/fmd-snoop/run/blacklist.txt','rt')
#                for i in f.readlines():
#                    if line[6] in i:
#                        result = 'fmdump -Ve -u %s' % (line[6])
#                f.close()
#                p.wait()
#                self.stdout2, self.stderr2 = pp.communicate()
#                f = open('/racktop/fmd-snoop/run/record.txt','wt')
#                f.write(stdout2)
#                f.close()

            time.sleep(2)

if __name__ == "__main__":
    daemon = MyDaemon('/racktop/fmd-snoop/run/fmd-snoop.pid')
    if len(sys.argv) == 2:
        if 'start' == sys.argv[1]:
            daemon.start()
        elif 'stop' == sys.argv[1]:
            daemon.stop()
        elif 'restart' == sys.argv[1]:
            daemon.restart()
        else:
            print "Unknown command"
            sys.exit(2)
        sys.exit(0)
    else:
        print "usage: %s start|stop|restart" % sys.argv[0]
        sys.exit(2)