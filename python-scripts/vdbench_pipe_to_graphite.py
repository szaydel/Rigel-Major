#!/usr/bin/env python

from __future__ import with_statement
import re
import getopt
import socket
import sys
import platform
import time

def getcmdline(args,opts):
    try:
        args, file = getopt.getopt(args,opts)
        return (args, file)

    except getopt.GetoptError:
        print "Error Encountered with options"
        return False

def readfromfile(filein,pattern):
    """ Function will consume a filename and a re.pattern,
    and will skip only line matching the pattern, which should be
    first line of input `header` and return all other lines one at a time.
    """
    with open(filein, 'rt') as lines:

        for line in lines:
            if not pattern.search(line):
                yield line.strip()
        lines.close()

def send_msg(message, dest):
    """ Function will take a list of message items to send
    and will iterate over this list """

    global counter
    if debug:
        print 'Sending message:\n%s' % message

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    if debug:
        print >>sys.stderr, 'Connecting to: %s port %s' % (carbsrv, carbport)
    try:
        sock.connect(dest)
    except socket.error, e:
        print >>sys.stderr, 'Unable to connect to %s, error %s\n' % (carbsrv, e)
        sys.exit(1)
    
    try:
        # Send message to server, one list element at a time
        for i in message:
            if debug:
                print >>sys.stderr, 'sending "%s"' % i
            if not debug:
                sock.sendall(i)
            else:
                pass
    finally:
        counter+=1
        print >>sys.stderr, 'Event Count: %s' % counter
        sock.close()
        return True

    # sock.sendall(message)
    # sock.close()

def sliceit(x):

    """0)time 1)Run 2)Xfersize 3)MB/sec 4)Read_rate 5)Read_resp
    6)Write_rate 7)Write_resp 8)MB_read 9)MB_write
    10)ks_rate 11)ks_resp 12)ks_wait 13)ks_svct 14)ks_avwait 15)ks_avact
    16)cpu_used 17)cpu_user 18)cpu_kernel 19)cpu_wait 20)cpu_idle
    """
    li = x
    timestamp = li[0]
    name_of_rd = li[1]
    xfersize = li[2]
    total_mb_sec = li[3]
    read_sec = li[4]
    read_latency = li[5]
    write_sec = li[6]
    write_latency = li[7]
    read_mb_sec = li[8]
    write_mb_sec = li[9]
    ks_io_rate = li[10]
    ks_latency = li[11]
    ks_host_wait = li[12]
    ks_svct = li[13]
    ks_avwait = li[14]
    ks_avact = li[15]
    ks_cpu_used = li[16]    ## CPU used time, percentage of 100
    ks_cpu_user = li[17]    ## CPU time in user mode, percentage of 100
    ks_cpu_kernel = li[18]      ## CPU time in kernel mode, percentage of 100
    ## ks_cpu_wait = li[19]      ## CPU time waiting on CPU, percentage of 100
    ## ks_cpu_idle = li[20]      ## CPU time idle, waiting for work, percentage of 100

    ## Dictionary containing statistics elements from input line
    ## for future use, at the moment
    stat_dict = {
        'xfersize':xfersize,
        'total_mb_sec':total_mb_sec,
        'read_sec':read_sec,
        'read_latency':read_latency,
        'write_sec':write_sec,
        'write_latency':write_latency,
        'read_mb_sec':read_mb_sec,
        'write_mb_sec':write_mb_sec,
        'ks_io_rate':ks_io_rate,
        'ks_latency':ks_latency,
        'ks_host_wait':ks_host_wait,
        'ks_svct':ks_svct,
        'ks_avwait':ks_avwait,
        'ks_avact':ks_avact,
        'ks_cpu_used':ks_cpu_used,
        'ks_cpu_user':ks_cpu_user,
        'ks_cpu_kernel':ks_cpu_kernel,
        }

    ## Below, result is a tuple of select elements from slicing
    ## the above list

#    result = (int(timestamp), name_of_rd, xfersize, total_mb_sec,
#        read_sec, read_latency, write_sec, write_latency,
#        read_mb_sec, write_mb_sec, ks_io_rate, ks_latency,
#        ks_host_wait, ks_svct, ks_avwait, ks_avact,
#        ks_cpu_used, ks_cpu_user, ks_cpu_kernel)

    result = (int(timestamp),name_of_rd,stat_dict)

#    if debug:
#        print 'Length of `result` tuple is %d, Length of stat_dict is %d' \
#        % (int(len(result)), int(len(stat_dict)))
    return result

if __name__ == '__main__':

    args,file = getcmdline(sys.argv[1:],'-v') # Get filename from argv array

    if not file:
        print >>sys.stderr, 'Missing input filename. Try again!'
        sys.exit(1)

    elif len(file) > 1:
        print >>sys.stderr, "Cannot accept more than one input file. Try again!"
        sys.exit(1)

    else:
        input_file = file[0]

    debug = 1
    counter = 0
    carbsrv = '10.10.100.11'
    carbport = 2003
    target_machine = (carbsrv, carbport)
    delay = 2  # secs
    node = platform.node().replace('.', '-')
    pattern = re.compile(r'^Run')      # RegEx obj matching header row in results
    message = []
    msgc = 0
    if debug: limit = 2     # This is just to speed up testing
    else: limit = 100

    while True:

        datain = readfromfile(input_file,pattern)

        for line in datain:
            line = line.rstrip('\n').split()    # list from string
#            print line
            res = sliceit(line)      # res is a tuple
#            print line
#            timestamp = int(time.time())

            # Taking in a tuple of three elements from sliceit() and
            # building a list of lines

            ### Structure of the resulting tuple is as follows: ###
            # [integer=>timestamp, string=>name_of_run_definition, dictionary =>stats ]

            lines = [ 'system.%s.io.vdbench.%s %s %d' %
                     (node,i[0], i[1], res[0]) for i in res[2].items() ]

#        if debug:
#            sys.exit(0)     # At the moment we are exiting prematurely, for testing.

            ''' We are trying to reduce the amount of TCP connections by
            aggregating messages collected into a list, and then looping over
            the list, delivering messages with one open/close event '''
            message.append('\n'.join(lines) + '\n')

            if debug:
                print '%s' % message

            if not debug:
#                send_msg(message,target_machine)
                msgc += 1       # Increment counter by `1` with addition of each new line
                if msgc == limit:   # Once we reached number of messages to collect, we push
                    try:
                        res = send_msg(message, target_machine)
                    except IOError:
                        retry = 0       # Limit number of retries to 3
                        while retry < 3:
                            res = send_msg(message, target_machine)
                            if res:
                                break
                            retry += 1

                        if not res and retry == 3:
                            sys.exit(1)

                    finally:
                        message = []        # Empty our list after sending
                        msgc = 0      # Reset msgc after
                time.sleep(delay)