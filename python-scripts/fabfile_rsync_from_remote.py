#!/usr/bin/env python
#from fabric.api import *
#from fabric.api import abort, cd, env, get, hide, hosts, local, prompt, \
#    put, require, roles, run, runs_once, settings, show, sudo, warn



'''
All possible environment variables that we can change with settings
from fabric.context_managers import env
env.viewkeys()
env.items()
dict_keys(['real_fabfile', 'shell', 'roles', 'passwords', 'show',
'always_use_pty', 'key_filename', 'all_hosts', 'sudo_prompt', 'again_prompt',
'host', 'no_agent', 'user', 'reject_unknown_hosts', 'path', 'path_behavior',
'roledefs', 'port', 'rcfile', 'password', 'hide', 'sudo_prefix','lcwd',
'output_prefix', 'fabfile', 'combine_stderr', 'use_shell', 'echo_stdin',
'host_string', 'version', 'command', 'warn_only', 'hosts', 'command_prefixes',
'no_keys', 'cwd', 'local_user', 'disable_known_hosts'])
'''

from fabric.api import local as run_local
from fabric.api import hide
from fabric.context_managers import lcd as localcd
from fabric.context_managers import path
from fabric.context_managers import settings
from fabric.context_managers import env
from os import path
from os import walk
from os import environ
from os import system
from os import stat
from socket import gethostname

local_hostname = gethostname()

'''
rsync_host = 'filer-nex-lab3'
rsync_path = '::lab3_pool_a_data02_alpha_d00/'
a = rsync_mir(rsync_host,rsync_path)
'''

rsync_host = 'filer-nex-lab3'
rsync_path = '::lab3_pool_a_data02_alpha_d00/'
def rsync_mir(from_server,from_path):
    with settings(
        hide('warnings', 'running', 'stdout', 'stderr'),
        warn_only=True,
        capture=True
    ):
        workdir = run_local('pwd',capture=True)
        if not workdir == '/tmp':
            print 'BAD'
            with localcd('/tmp'):
                cwd = run_local('pwd',capture=True)
                print '%s == %s' % ('Changed path to:', cwd); 
                results = run_local('/usr/bin/rsync '+from_server+from_path,capture=True)
                return results