#!/usr/bin/env python
################################################################################
### Collect STMF information specifically, target + lun information ############
################################################################################
#: Title       : COMSTAR LUN and Target Collection Utility
#: Date        : 2011-10-08
#: Rev. Date   : ##
#: Author      : Sam Zaydel
#: Version     : 1.0.0
#: Description : Currently we are gathering only some details about COMSTAR
#:             : targets and LUNs existing on the system. We will need to 
#:             : collect more data at some point, and perhaps allow arguments
#:             : to be passed into the script. At the moment this does not exist.
#: Options     : Future...
#: Path to file: not important, uses absolute paths, so can reside anywhere
##  
################################################################################
import sys
from subprocess import Popen
from subprocess import PIPE
from datetime import datetime
from time import sleep
import re

import subprocess,sys
def run_command(command, *args):
    retcode = ''
    ## Build list which we will use as argument to subprocess.Popen
    cmd_line = [i for i in iter(args)]; cmd_line.insert(0,command)
    try:
        proc = Popen(cmd_line,stdin=PIPE,stdout=PIPE,stderr=PIPE)
        ## This variable will not exist if the except clause
        ## is triggered, due to failure to run command
        retcode = proc.wait()

        ## If the return code collected from proc.wait() is non-zero
        ## we are not going to return any data, instead will return False
        if not retcode == 0:
            print >>sys.stderr,'%s: %d' \
            % ('Child terminated with signal',retcode)
            return False
        # *** Will not work with python 2.5 ***
        #    print >>sys.stderr,'{0}: {1:d}'.format(
        #        'Child terminated with signal'
        #        ,retcode)
    ## We are only going to return something meaningful 
    ## if we were able to call the command and return was 0
        else:
            return proc.communicate()
    except OSError:
        print 'EXEC Failed:%s, with %s' % (cmd_line, sys.exc_info()[1])
        return False

def parse(expr,text):
    match = re.findall(expr, text)
    return match

## Begin Main portion of the script, function above is useful for import
if __name__ == '__main__':

    luns = run_command('stmfadm','list-lu')
    #luns = luns[0].split('\n')
    parsed_luns = parse(r'[\d.]+[\w\d]+', luns[0])

    ## Collecting target group information for all targets
    #tg_info = run_command('stmfadm','list-tg', '-v')

    target_info = run_command('stmfadm','list-target')
    targets = parse(r'iqn\.[\w\d\-\:\.]+', target_info[0])
    if targets:
        for tgt in targets:
            target_details = run_command('stmfadm','list-target','-v',tgt)
            print target_details[0]

    ## Building a simple dictionary where each guid is the key,
    ## and each value is list of details about the LUN, including
    ## target group, host group LUN number, etc.
    LunInfoDict = {}
    for lun in parsed_luns:
        data = run_command('stmfadm','list-view', '-l', lun)
        mapping = parse(r': (\w+)',data[0])
        LunInfoDict[lun] = mapping[1:4]
    
    ## Map values inside each list referenced by given key
    ## to a more human-friendly identifier
    for k in LunInfoDict:
        lun_guid,hg,tg,lun_n = k,LunInfoDict[k][0], \
                                LunInfoDict[k][1], \
                                int(LunInfoDict[k][2])

        ## Collect more details about each LUN, including status, 
        ## state, provider, ZVOL-block info, etc.
        lun_details = run_command('stmfadm','list-lu', '-v',k)
        if lun_details:
            lun_details = lun_details[0]
        #print 'LUN [%d] / GUID: %s\nTarget Group: \t%s\nHost Group: \t%s\n\nDetails:\n%s\n' \
        #      % (lun_n,lun_guid,tg,hg,lun_details)
        
        ## Organize and print collected data out to the screen
        print 'LUN Number:\t[%d]\nTarget Group:\t%s\nHost Group:\t%s\n\nDetails:\n%s\n' \
            % (lun_n,tg,hg,lun_details)
    #print tg_info[0]
        #x = re.findall('[0-9].+',lun)[0].rstrip('\n')
        #parsed_luns.append(x)
    #print parsed_luns