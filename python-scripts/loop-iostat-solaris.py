#!/usr/bin/env python
################################################################################
### Using the subprocess module to run a command passed from the main body #####
################################################################################
#: Title       : Generic script to loop over a command with arguments
#: Date        : 2011-08-24
#: Rev. Date   : ##
#: Author      : Sam Zaydel
#: Version     : 0.1.3
#: Description : Could be used as a module if imported and standalone
#:             : Will create a log file under /tmp with results of the run
#: Options     : None yet, will add later
#: Path to file: not-defined
##
import sys
from subprocess import Popen
from subprocess import PIPE
from datetime import datetime
from time import sleep
    
def run_subproc(cmdline,x):
    try:
        # iostat_out,iostat_err = "",""
        subproc_cmd = Popen(cmdline, stdout=PIPE,stderr=PIPE)
        retcode = subproc_cmd.wait()
        
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
        else:
            return (subproc_cmd)
    except OSError, e:
        return (subproc_cmd,e)

## Begin Main portion of the script, function above is useful for import
if __name__ == '__main__':

    ## Each variable below will become a command-line option next time 
    command = ['/usr/bin/iostat','-XxDnzTd']
    counter = 1
    #delay = 2 # seconds to wait until restarting the loop
    #instances = 4 # how many times to actually run the loop
    #timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    #logfile = '/tmp/iostat-'+timestamp+'.log'
    #command = ['/usr/bin/iostat','-x','-k']
    #counter = 1
    #delay = 2
    #instances = 4
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    
    import optparse

    parser = optparse.OptionParser(description= \
                    'Wrapper for iostat to dump output to logfile',\
                    usage='%prog [-h --help -r --repeat -d --delay -o --output-log /path/to/logfile]')
    
    parser.add_option('-r','--repeat',\
                      help='Set number of times to run the command',\
                      action='store',\
                      type='int',\
                      dest='instances')
    
    parser.add_option('-d','--delay',\
                      help='Set delay between execution of each iteration of command',\
                      action='store',\
                      type='int',\
                      dest='delay')
    
    parser.add_option('-o','--output-log',\
                      help='Output log file to write to, if none will write log to: '+'/tmp/iostat-'+timestamp+'.log',\
                      action='store',\
                      type='string',\
                      dest='logfile')

    if len(sys.argv[:]) <= 1:
        parser.print_usage()
        sys.exit(1)
        
    opts,args = parser.parse_args()
    #instances = opts.instances
    #delay = opts.delay
    #logfile = opts.logfile
    
    if opts.logfile == None:
        logfile = '/tmp/iostat-'+timestamp+'.log'
    else:
        logfile = opts.logfile
    
    ## Define instances to run, if not set, use default of '4'
    if opts.instances == None:
        instances = 4
    else:
        instances = opts.instances
    ## Define delay between runs, if not set, use default of '1'    
    if opts.delay == None:
        delay = 1
    else:
        delay = opts.delay
    
    #print instances,delay,logfile
    #sys.exit(0)
    
    ## We need to add (s) for appearance, if delay is greater than 1 second
    if delay > 1:
        plu = '(s)'
    else:
        plu =''
    ## As long as counter is less than # of instances, keep loop alive        
    while counter <= instances:
        ## results should be our Popen object returned by the function run_subproc
        results = run_subproc(command,'4')
        ## We need to write this to a file using a byte-string
        # with open(logfile,'ab') as f:
        f = open(logfile,'ab')
        f.write('Sequence'+' ['+str(counter)+'] '+'### Start Output ###\n'.encode('UTF-8'))
        f.write(results.stdout.read())
        f.write('Sequence'+' ['+str(counter)+'] '+'### Stop  Output ###\n\n'.encode('UTF-8'))
        f.close()
        print 'Call %5s ### %2d out of %d, every %d sec%s ###' \
        % (str(command).strip('[]'),counter,instances,delay,plu)
        sleep(delay)
        counter += 1
    print 'Sent output from %d runs of cmd to %s' % (instances,logfile)

    ## At this point we can safely exit with '0'
    sys.exit(0)