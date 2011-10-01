#!/usr/bin/env python
from fabric.api import *
#from fabric.api import abort, cd, env, get, hide, hosts, local, prompt, \
#    put, require, roles, run, runs_once, settings, show, sudo, warn
from os import path

@hosts('server03')
def simple_get():
    with open('/etc/lsb-release','ra') as f:
        for a in f.readlines():
            if 'RELEASE' in a:
                rel_ver = a.split('=')[1].strip('\n')
        f.close()
        
    #file = '/infra/repo/push-configs/laptops/'+rel_ver+'/'+'test-file-1'
    file = path.join('/tmp',rel_ver)
    print file
    
    #file = str(file)
    ret = get(remote_path=file,local_path='%(path)s')
    
    if ret.succeeded is True:
        print 'Successfully retrieved %s' % (file)
    else:
        print 'Failed to retrieve %s' % (file)
