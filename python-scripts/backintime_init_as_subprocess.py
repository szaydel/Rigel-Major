#!/usr/bin/env python3.1
#
##
###
###

import datetime,logging,os,sys,subprocess

test_mode = 'y'
mount_cmnd = '/bin/mount'
bit_cmnd = '/usr/bin/backintime'
bkups_dir = '/export/nfs/backups'
logs_dir = os.path.join(bkups_dir,'logs')
process_name = 'backintime'
runas = os.environ['USER']
self_name = os.path.basename(sys.argv[0])

## If we are running the script in testing mode
if test_mode == 'y':
    bkups_dir = '/tmp'
    logs_dir = os.path.join(bkups_dir,'logs')
    bit_cmnd = '/bin/ls'

def main_log_func(log_fn=None, mode=None, level=logging.DEBUG, \
                    format='%(asctime)s|%(name)s|%(levelname)s| %(message)s'):
    '''
    simplest basicConfig wrapper, open log file and return default log handler
    '''
    ## Define name of the log file, if one does not exist
    if log_fn is None:
        now = datetime.datetime.now()
        time_stamp = now.strftime('%Y%m%d_%H%M%S')
        log_fn = os.path.join(logs_dir, '%s-%s-%s.log' % (process_name,runas,time_stamp))
        
    if mode is None:
        mode = 'a'

    logging.basicConfig(level=level,
                        format=format,
                        filename=log_fn,
                        filemode=mode)

    logger = logging.getLogger(runas)
    if mode.lower() == 'a':
        logger.info('---=== START : '+process_name+' : ===---')

    return logger

def alert (pri,runas,msg):
    # logger_n = main_log_func()
    w = logger
    if pri == 'info':
        w.info(msg)
    elif pri == 'warning':
        w.warn(msg)
    elif pri == 'error':
        w.error(msg)


def mount_dir(cmd,dir):
    ## We define arguments in a form of a tuple which we
    ## later pass as one argument to 'subprocess'
    args = [cmd,dir]
    print(args)
    x = subprocess.Popen([cmd,dir], \
                        shell=False,stdout=subprocess.PIPE,\
                        stderr=subprocess.PIPE)
    return_code = x.wait()
    out,err = x.communicate()
    
    if not return_code == 0:
        try:
            os.path.exists(logs_dir)
        except IOError as err:
            print('I/O error: {0}'.format(err))

        #alert('error',runas,err.decode())
        # return (return_code,err.decode())
        # print('MyPID',x.pid,'My Return Code',return_code)
    else:
        # main_log = main_log_func()
        alert('info',runas,out.decode())
        return (return_code,out.decode())
    
def run_backintime(cmd):
    # args = [cmd,'--backup-job']
    args_b = [cmd,'/ddd']
    args_g = [cmd,'/tmp']
    x = subprocess.Popen(args_g, \
                        shell=False,stdout=subprocess.PIPE,\
                        stderr=subprocess.PIPE)
    
    out,err = x.communicate()
    return_code = x.poll()
    ## Write information to the logfile including details captured from
    ## stdout and stderr
    ## We will write stderr to the log if the return code is not '0',
    ## otherwise we will write stdout to the log
    if not return_code == 0:
        alert('error',runas,'Backup job failed to complete.')
        alert('error',runas,err.decode())
    else:
        alert('info',runas,'Backup job completed successfully.')
        alert('info',runas,'Results from running' + \
              ' ' +process_name+'\n' + out.decode())
    
    logger.info('---=== END : '+process_name+' : ===---')
    return (return_code,out,err)

################################################################################
#### Start of Main program #####################################################
################################################################################
if __name__ == '__main__':
    
    print(os.path.join(logs_dir,self_name))
    print(os.path.basename(sys.argv[0]))
    
    ## Once we create our logger, we can reference it in other functions
    ## such as the alert function
    logger = main_log_func()
    mount_dir(mount_cmnd,bkups_dir)
    #main_log.info('message')
    #main_log.fatal('exit')
    run_backintime(bit_cmnd)
    