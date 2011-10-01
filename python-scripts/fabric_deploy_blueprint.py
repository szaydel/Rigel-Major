#!/usr/bin/env python

## Switching into a directory and executing 'ls'
#from fabric.api import cd as fab_cd
from fabric.api import lcd as fab_lcd
from fabric.api import local as fab_local
from fabric.api import run as fab_run
from fabric.api import prompt as fab_prompt
from fabric.operations import put as fab_put
from fabric.api import task
from fabric.tasks import Task
from fabric.context_managers import env
from fabric.context_managers import settings
from fabric.context_managers import show
from sys import exit as sys_exit
import cStringIO

## Debug setting, set to '1' to run everything locally
debug = 1
## All things we can import from fabric.api
# ['abort', 'cd', 'env', 'fastprint', 'get', 'hide', 'hosts', 'lcd', 
# 'local', 'open_shell', 'output', 'path', 'prefix', 'prompt', 
# 'put', 'puts', 'reboot', 'require', 'roles', 'run', 'runs_once', 
# 'settings', 'show', 'sudo', 'task', 'warn', 'with_settings']

## All things we can import from fabric.context_managers
# ['_change_cwd', '_set_output', '_setenv', 'cd', 'char_buffered', 
# 'contextmanager', 'env', 'hide', 'lcd', 'nested', 'output', 'path', 
# 'prefix', 'settings', 'show', 'sys', 'termios', 'tty', 'win32']

class RunTasksClassSnd(Task):
    name = "send_blueprint"
    def __init__(self, func, src_path, target_path):
        self.func = func
        self.src_p = src_path
        self.target_p = target_path
    
    def run(self, *args, **kwargs):
        return self.func(self.src_p, self.target_p, *args, **kwargs)
        #print 'Something imp...', args
        #return self.func(*args, **kwargs)
@task(task_class=RunTasksClassSnd,
        src_path='/tmp/myfile',
        target_path='/tmp/myfile-on-target')

def send_blueprint_script(src_path,target_path):
    with settings(show('warnings', 'running',
                        'stdout', 'stderr'), 
                        warn_only=False,
                        shell='/bin/bash -lc',
                        user='labadm',
                        ):
        ## try/except wrapped check to validate existance of local file
        try:
            with open(src_path, 'rt') as f:
               f.readline()
        except IOError as e:
            print "I/O error [{0}] {1}: {2}".format(e.errno, e.strerror, e.filename)
            sys_exit(1)


        test_exist = fab_run('ls -l %s' % (target_path))
        if test_exist.succeeded:
            replace_yesno = fab_prompt(
            'File <{0}> already Exists. OK to Replace? [yes/no]'.format(target_path),
            default='no')

        if debug == True:
            print 'You said [{0}], exiting.'.format(replace_yesno)
            if 'yes' in replace_yesno.lower():
                replace_yesno = True
            else:
                replace_yesno = False
                
                #ch = lambda x: 'yes' if x == True else 'no'
            sys_exit(0)

            test = fab_put(src_path,target_path,use_sudo=False, mirror_local_mode=False, mode=None)
        else:
            test = fab_run('[ -f %s ]' % (lsbdata))
        # if test.succeeded:
        #     if debug == True:
        #         lsb_conts = fab_local("cat %s " % (lsbdata), capture=True)
        #     else:
        #         lsb_conts = fab_run("cat %s " % (lsbdata))


## Validate version of the operating system
class RunTasksClassDep(Task):
    name = "deploy_blueprint"
    def __init__(self, func, data):
    #def __init__(self, func):
        self.func = func
        self.data = data
    def run(self, *args, **kwargs):
        return self.func(self.data, *args, **kwargs)

## Validate version of the operating system
@task(task_class=RunTasksClassDep,data='/etc/lsb-release')
def validate_os(lsbdata):
    
    with settings(show('warnings', 'running',
                       'stdout', 'stderr'), warn_only=True,shell='/bin/bash -lc'):
        if debug == True:
            test = fab_local('[ -f %s ]' % (lsbdata), capture=True)
        else:
            test = fab_run('[ -f %s ]' % (lsbdata))
        if test.succeeded:
            if debug == True:
                lsb_conts = fab_local("cat %s " % (lsbdata), capture=True)
            else:
                lsb_conts = fab_run("cat %s " % (lsbdata))
            ## Convert string to a StringIO object, to ease converting
            ## to a dictionary
            ## Seems like extra work, but this is meant
            ## to ease future improvements to this code
            lsbIO = cStringIO.StringIO(lsb_conts)
            
            ## Build dictionary with dict. comprehension
            ## Stripping '\r' is only required when execuing remotely
            lsbdata_d = { k:v for k,v in
                        [ a.strip('\n').strip('\r').split('=') 
                        for a in lsbIO.readlines() ] }

            if debug: print '<Debug Enabled> Flag Raised after building lsbdata_d Dict'             
            if lsbdata_d['DISTRIB_ID'].lower() == 'ubuntu':
               
                if debug == True:
                    result = fab_local('echo This is where we would execute our deploy.')
                    if result.succeeded:
                        #print 'Succeeded!'
                        return True
                    else:
                        return False
                else:
                    result = fab_run('echo This is where we would execute our deploy.',shell=True)
                    if result.succeeded:
                        #print 'Succeeded!'
                        return True
                    else:
                        return False
            else:  
                return False
        else:
          return False
# @task(alias='dbp',task_class=CT,dir_p=['/moo','/tmp'])
# def actual_task(dir_p='/',env='lab'):
#     print '%s' % ('Testing, testing...')
#     print dir_p
#     with settings(show('warnings', 'running',
#          'stdout', 'stderr'), warn_only=True):
#         for a in dir_p:
#             print a
#             with fab_lcd(a):
#                 result = fab_local('ls -l', capture=True)
#                 print 'Current Environment :: %s' % (env)
#                 #print result
#             result = ''

class MyDebugTask(Task):
    name = "debug_task"
    def run(self, *args):
        print args
        fab_local("echo MyDebugTask being called.")
        #sudo("service apache2 restart")

instance = MyDebugTask()