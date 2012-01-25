#!/usr/bin/env python
import re
from fabric.api import abort as fab_abort
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
default_shell = '/usr/bin/bash --noprofile -lc'
nmc_cmd = '/usr/bin/nmc -c'
grep_cmd='/usr/bin/grep -v'
zfs_spa_cmd = '/usr/sbin/zfs list -r -ospace -H'

## Format specifiers for various tasks
show_space_usage_fmt = 'Name: {0[0]:s}\n \
Available:.................{0[1]:10s}\n \
Total Used:................{0[2]:5s}\n \
Used by Snapshots:.........{0[3]:5s}\n \
Used by Dataset:...........{0[4]:5s}\n \
Used by Refreservation:....{0[5]:5s}\n \
Used by Children:..........{0[6]:5s}\n'

def write_line(l=80,char='-'):
    if not l == int(l):
        l = 80
    print '%s' % (char * int(l))

## Generic function
def remove_trailing_junk(x):
    return (lambda y: x.replace(y,''))

def organize_dataset_list(x):
    fi_obj = [ i for i in cStringIO.StringIO(x) ]
    final_zvols = []
    for line in fi_obj:
        mystr = line
        for i in '\n', '\r':
            a = remove_trailing_junk(mystr)
            mystr = a(i)
        final_zvols.append(mystr.split(' '))
    return final_zvols

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

@task
def list_zvol_test (zfs_cmd='/usr/sbin/zfs', tr_cmd='tr',nmc_cmd='nmc -c'):
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
            final_zvols = organize_dataset_list(result)
            #print final_zvols
            print '%s' % ('')
            write_line(char='x')
            print '>> Task Succeeded: [%s] >> Total ZVOL Count: [%d]' % ('show_zvol',len(final_zvols))
            write_line(char='x')
            for line in final_zvols:
                ofields = (line[0],line[1],line[2],line[3])
                print 'Name: {0[0]:s}\nUsed: {0[1]:10s}Avail: {0[2]:10s} Refer: {0[3]:10s}'.format(ofields)
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
                ''' This may seem odd, but using cstringio seems
                to actually work very well in this particular instance
                '''
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
 

''' Task collects list of volumes, if no volumes are specified 
all will be returned. Else if a volume name is given as a value to arg 'vol',
function is expected to return name of the volume assuming volume exists, or 
False is the name does not exist.
'''
@task
def get_volume (zpool_cmd='/usr/sbin/zpool list -H -oname',vol=''):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell=default_shell, user='admin'):
        ## If there is no value for 'val', result will be a list,
        ## because we assume more than one volume/pool on system
        if not vol:
            result = fab_run('%s' % (zpool_cmd)).split('\n')
        else:
            result = fab_run('%s %s' % (zpool_cmd, vol))

        if result.succeeded:
            #print result
            return result

            result = [i.strip('\r') for i in result]
            #print result
            return result
        else:
            return False

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

''' This is a function which will run recursively, and
is expected to return a list of all datasets within
a supplied pool
'''
@task(alias='show_sp')
def show_space_usage (zfs_cmd='/usr/sbin/zfs', 
    tr_cmd='/usr/bin/tr', 
    nmc_cmd='/usr/bin/nmc -c', 
    tr = 'tr \'[[:blank:]]\'  \' \'',
    dataset=''):
    with settings(
    hide('running', 
    'stdout', 
    'stderr'),
    warn_only=True, always_use_pty='false',
    shell=default_shell, user='admin',):

        ''' Testing to see if dataset is name of pool only, or
        name of pool including child dataset
        ''' 
        if not dataset == dataset.split('/'):   ## is '/' in the name
            validate = get_volume(vol=dataset.split('/')[0])
        else:
            validate = get_volume(vol=dataset)

        ''' Next, we need to confirm that pool name is valid
         and exists on the target SAN
        '''
        if validate == False:
            
            fab_abort('Invalid Volume Name {0}, Please check name.'.format(dataset))
            print 'FAILED!!!'
        else:
            result = fab_run('%s %s|%s' % (zfs_spa_cmd, dataset, tr))
        
        if result.succeeded:
            final_space_usage = organize_dataset_list(result)
            #print final_zvols
            print '%s' % ('')
            write_line(char='x')
            print '>> Task Succeeded: [%s] >> Total Dataset Count: [%d]' % \
            ('show_zvol',len(final_space_usage))
            write_line(char='x')
            for line in final_space_usage:
                ofields = (line[0],line[1],line[2],line[3],
                line[4],line[5],line[6])
                print show_space_usage_fmt.format(ofields)
            return True
        else:
            return False
