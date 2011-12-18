#!/usr/bin/env python
import re
from fabric.api import lcd as fab_lcd
from fabric.api import local as fab_local
from fabric.api import run as fab_run
from fabric.api import prompt as fab_prompt
from fabric.operations import put as fab_put

from fabric.api import settings, env
#from fabric.context_managers import env
#from fabric.context_managers import settings
from fabric.context_managers import hide
from fabric.context_managers import show
from sys import exit as sys_exit

from fabric.api import task
from fabric.tasks import Task
import cStringIO

env.hosts = ['server-lab9.homer.lab']
#env.user = ['admin']
## Commands
nmc_cmd = '/usr/bin/nmc -c'

# class MyTask(Task):
#     name = "dummy"
#     def run(self, environment, domain="whatever.com"):
#         run("git clone foo")
#         sudo("service apache2 restart")

# instance = MyTask()

def write_line(l=80,char='-'):
    if not l == int(l):
        l = 80
    print '%s' % (char * int(l))

def parse_zvol_info():
    

@task
def get_checkpoints(nmc_cmd='nmc -c', domain="whatever.com"):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell='/usr/bin/bash --noprofile -lc', user='admin'):
        #fab_local('echo Env: {0} and Dom: {1}'.format('moo','yaya.com'))
        capture = fab_run('%s %s' % (nmc_cmd, '\"show appliance checkpoint\"'))

        if capture.succeeded:
            for line in capture.split('\n'):
                pattern = re.compile(r'^rootfs', re.IGNORECASE)
                match = re.match(pattern, line)
                ## Match the heading of available checkpoints list, 
                ## and decorate with '^'
                if match and match.group() == match.group().upper():
                    print '%s' % ('^' * 80)
                    print line
                    print '%s' % ('^' * 80)
                elif match:
                    print line
                else:
                    pass

@task
def list_zvol (zfs_cmd='/usr/sbin/zfs', tr_cmd='tr',nmc_cmd='nmc -c'):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell='/usr/bin/bash --noprofile -lc', user='admin',):

        result = fab_run('%s %s | %s %s' % (zfs_cmd, 
        'list -t volume -H -oname,used,avail,refer',
        tr_cmd, '"\t" " "'))

        if result.succeeded:
            import cStringIO
            fi_obj = cStringIO.StringIO(result).readlines()
            final_zvols = []
            print '%s' % ('')
            write_line(char='x')
            print '>> Task Succeeded: [%s] >> Total ZVOL Count: [%d]' % ('show_zvol',len(fi_obj))
            write_line(char='x')
            print '%s' % ('')
            for line in fi_obj:
                for end in ['\n','\r']:
                    line = line.replace(end,'')
                line = line.split(' ')
                final_zvols.append(line)
                ofields = (line[0],line[1],line[2],line[3])
                print 'Name: {0[0]:s}\nUsed: {0[1]:10s}Avail: {0[2]:10s} Refer: {0[3]:10s}'.format(ofields)
                write_line()
            return True
        else:
            return False

@task(alias='show_zvm')
def show_zvol_more_info (nmc_cmd='/usr/bin/nmc -c', 
    zvol_path=''):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell='/usr/bin/bash --noprofile -lc', user='admin',):

        if zvol_path == '':
            ## Assuming that we are geting list for all ZVOLs
            result = fab_run('%s "%s"' % (nmc_cmd, 'show zvol -v'))
            ## If we succeed we just want to return result
            if result.succeeded:
                print result
                return True
            else:
                return False
        
        ## Selecting individual zvol by name, assuming zvol_p is not empty
        elif not zvol_path == '':
            result = fab_run('%s "%s %s"' % (nmc_cmd, 'show zvol -v',zvol_p))
            ## If we succeed we just want to return result
            if result.succeeded:
                print result
                return True
            else:
                return False

##
## List snapshots on the SAN
##
@task(alias='list_snp')
def list_snapshot (nmc_cmd='/usr/bin/nmc -c', 
    grep_cmd='/usr/bin/grep -v', dataset=''):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell='/usr/bin/bash --noprofile -lc', user='admin',):

        if dataset == '':
            ## Assuming that we are geting list for all ZVOLs
            result = fab_run('%s "%s"|%s %s' % (nmc_cmd, 'show snapshot -r -Screation', 
            grep_cmd, '^NAME'))
            ## If we succeed we just want to return result
            if result.succeeded:
                import cStringIO
                fi_obj = cStringIO.StringIO(result).readlines()
                final_snapshots = []
                write_line(char='x')
                print '>> Task Succeeded: [%s] >> Total Snapshot Count: [%d]' % ('list_snapshot',len(fi_obj))
                write_line(char='x')
                for line in fi_obj:
                    for end in ['\n','\r']:
                        line = line.replace(end,'')
                    line = line.split(' ')
                    print line[0]
                    final_snapshots.append(line[0])
                    #print final_snapshots
                return True
            else:
                return False
        
        ## Selecting individual zvol by name, assuming zvol_p is not empty
        elif not zvol_p == '':
            result = fab_run('%s "%s %s"' % (nmc_cmd, 'show zvol -v',zvol_p))
            ## If we succeed we just want to return result
            if result.succeeded:
                print result
                return True
            else:
                return False
 

## Get list of volumes 
@task
def get_volume (cmd='/usr/sbin/zpool list -H -oname'):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell='/usr/bin/bash --noprofile -lc', user='admin'):
        #fab_local('echo Env: {0} and Dom: {1}'.format('moo','yaya.com'))

        #fab_run('%s' % ('/usr/bin/true'))
        capture = fab_run('%s' % (cmd))
        #print capture
        #print capture
        return [i.strip('\r') for i in capture.split('\n') if not i == 'syspool']

@task
def show_volume_details (cmd='/usr/sbin/zpool status -v'):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell='/usr/bin/bash --noprofile -lc', user='admin'):
        zpools = get_volume()
        for i in zpools:
            print i
            capture = fab_run('%s %s' % (cmd, i))
            print capture
