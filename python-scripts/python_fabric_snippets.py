#!/usr/bin/env python

## Switching into a directory and executing 'ls'
#from fabric.api import cd as fab_cd
from fabric.api import lcd as fab_lcd
from fabric.api import local as fab_local
from __future__ import with_statement

with fab_lcd('/tmp'):
    files = [ a for a in fab_local('ls',capture=True).split('\n') ]

## All things we can import from fabric.api
# ['abort', 'cd', 'env', 'fastprint', 'get', 'hide', 'hosts', 'lcd', 
# 'local', 'open_shell', 'output', 'path', 'prefix', 'prompt', 
# 'put', 'puts', 'reboot', 'require', 'roles', 'run', 'runs_once', 
# 'settings', 'show', 'sudo', 'task', 'warn', 'with_settings']

## All things we can import from fabric.context_managers
# ['_change_cwd', '_set_output', '_setenv', 'cd', 'char_buffered', 
# 'contextmanager', 'env', 'hide', 'lcd', 'nested', 'output', 'path', 
# 'prefix', 'settings', 'show', 'sys', 'termios', 'tty', 'win32']

hosts_entry = {'host_a':'10.10.1.101','host_b':'10.10.1.102'}
with fab_lcd('/tmp'):
    for k,v in hosts_entry.iteritems():
    print '%s\t\t %s' % (k, v)
    #for k,v in izip(hosts_entry.keys(),hosts_entry.values()):
        #print '%s %-10s' % (k, v)


## Template to write entries into hosts files
import datetime
timenow = datetime.datetime.now().strftime("%Y%m%d,%H:%M:%S")
filename = 'foo.file'

hosts_entry = {'hostname_a':'10.10.1.101',
               'hostname_b':'10.10.1.102',
               'hostname_c':'10.10.1.103',
               }

with fab_lcd('/tmp'):
    fab_local("echo '## Entry created on %s' >> '%s'" % (timenow,filename))
    for k,v in hosts_entry.iteritems():
        entry = '%-24s%s' % (k,v)
        fab_local("echo '%s' >> '%s'" % (entry,filename))

## Slightly different version of above, using string.Template
import datetime
from string import Template
timenow = datetime.datetime.now().strftime("%Y%m%d,%H:%M:%S")
filename = 'foo.file'

hosts_entry = {'hostname_a':'10.10.1.101',
               'hostname_b':'10.10.1.102',
               'hostname_c':'10.10.1.103',
               }

with fab_lcd('/tmp'):
    fab_local("echo '## Entry created on %s' >> '%s'" % (timenow,filename))
    for k,v in hosts_entry.iteritems():
        template = Template('%-24s %s' % ('$ip_addr', '$host_n'))
        
        line = template.substitute(host_n=k,ip_addr=v)
        fab_local("echo '%s' >> '%s'" % (line,filename))

## Validate version of the operating system
def validate_os(lsbdata='/etc/lsb-release'):
    env['shell'] = '/bin/bash -lc'
    with settings(show('warnings', 'running',
                       'stdout', 'stderr'), warn_only=True):
        test = fab_local('[ -f %s ]' % (lsbdata), capture=True)
        print test.failed
        if test.succeeded: 
            return False
        else:
            fab_local("cat '/etc/lsb-release' ")