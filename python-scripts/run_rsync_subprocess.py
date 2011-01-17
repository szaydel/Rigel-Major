#!/usr/bin/python3.1
#
#
#
import sys,subprocess,os,shlex
from datetime import datetime as tdt
from sys import argv as argv_1, exit as exit
## Set timestamp

## Today's date '20110112183351'
timenow = tdt.now().strftime("%a, %Y-%m-%d %H:%M:%S")

## Create logfile variable, to be used later
logfile = '/var/log/cron-rsync.log'

def write_log_hf(prompt):
    ## Today's date '20110112183351'
    timestamp = tdt.now().strftime("%a, %Y-%m-%d %H:%M:%S")

    with open(logfile,'at') as f:
        f.write('#'*80+'\n')
        f.write(str('####'+'\t'+timestamp+' '+prompt+' of cron job: ############################\n'))
        f.write('#'*80+'\n')
        f.close()
        
def rsync_dirs(rsync_opts,source_dir,dest_dir):
    ## stdout,stderr = '',''
    subp_list = shlex.split(rsync_opts)
    ## Append source and destination to list of arguments 'subp_list', using
    ## the built-in append method
    [subp_list.append(i) for i in [source_dir,dest_dir]]
    print(subp_list)
    
    ## Define location of binary to use for rsync
    rsync_cmd = '/usr/bin/rsync'
    os.environ["RSYNC_RSH"] = 'ssh' ## We want to use 'ssh' as our remote shell

    x = subprocess.Popen(subp_list, executable=rsync_cmd, \
                         stdout=subprocess.PIPE,stderr=subprocess.PIPE, \
                        bufsize=4096,shell=True)

    ## Open log file in binary mode and write both stdout and stderr to 'log'
    with open(logfile,'ab') as log:
        ## Write error information first
        log.write(x.stderr.read())
        ## Write std out information second
        log.write(x.stdout.read())
        log.close()
    return x.wait()

## Two arguments will be passed as input to this script
## Original intent is for source to be some server in format:
## server_name:/path/to/files
args = argv_1[:]

if len(args) < 2:
    print('Unable to proceed, please supply source and destination.')
    exit(1)
    
# print(args)
## Define arguments which we will pass to the rsync with the 'subprocess.Popen'
source_dir,dest_dir = args[1],args[2]
rsync_args = '-avz --human-readable --progress'

## Write header to logfile, and close log
write_log_hf('Start')

return_status = rsync_dirs(rsync_args,source_dir,dest_dir)
## Write success or failure to the log
with open(logfile,'at') as f:
    if return_status == 0:
        f.write('%s %s %s' % ('Return code:',return_status,'Command Succeeded\n'))
    else:
        f.write('%s %s %s' % ('Return code:',return_status,'Command Failed\n'))
    f.close()

## Write footer to logfile, and close log
write_log_hf('  End')
    