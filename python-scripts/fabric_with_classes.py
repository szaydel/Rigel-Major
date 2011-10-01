#!/usr/bin/env python
#from __future__ import with_statement
from fabric.api import lcd as fab_lcd
from fabric.api import local as fab_local
from fabric.api import task
from fabric.tasks import Task
from fabric.context_managers import settings
from fabric.context_managers import show


class MyTask(Task):
    name = "deploy"
    def run(self):
        with settings(show('warnings', 'running',
         'stdout', 'stderr'), warn_only=True):
            fab_lcd(dir_p)
            result = fab_local('ls -l', capture=True)
            print 'Current Environment :: %s' % (env)
            print result

#env = 'lab'
#dir_p = ['/tmp','/var/log']
instance = MyTask(env='lab',dir_p='/tmp')

class CT(Task):
    name = "cus_task"
    def __init__(self, func, dir_p):
    #def __init__(self, func):
        self.func = func
        self.dir_p = dir_p
    def run(self, *args, **kwargs):
        return self.func(self.dir_p, *args, **kwargs)

@task(task_class=CT,dir_p=['/moo','/tmp'],alias='ct-dir')
def actual_task(dir_p='/',env='lab'):
    print '%s' % ('Testing, testing...')
    print dir_p
    with settings(show('warnings', 'running',
         'stdout', 'stderr'), warn_only=True):
        for a in dir_p:
            print a
            with fab_lcd(a):
                result = fab_local('ls -l', capture=True)
                print 'Current Environment :: %s' % (env)
                #print result
            result = ''