#!/usr/bin/env python

import socket
import sys
import platform
import time
#fileo = sys.stdin()
debug = 1

carbsrv = '10.10.100.11'
carbport = 2003
delay = 10  # secs

def readln():
    stdin = sys.stdin.readline()
    ## We need to ignore header lines from the command
    for i in ['Timestamp','Tracing']:
        if stdin.startswith(i):
            stdin = ''
    if stdin:
        return stdin
    else:
        print '%s' % ('Nothing this time, sleeping.')
        return False

def send_msg(message):
    print 'sending message:\n%s' % message
    sock = socket.socket()
    sock.connect((carbsrv, carbport))
    sock.sendall(message)
    sock.close()

def sliceit(x):
    li = x
    poolname = li[4]
    latency = li[5]
    total_MB = li[6]
    read_MB = li[7]
    write_MB = li[8]
    total_IO = li[9]
    read_IO = li[10]
    write_IO = li[11]
    read_avgb = li[12]
    write_avgb = li[13]
    throttle = li[14]
    ''' Below, result is a tuple of select elements from slicing
    the above list '''
    result = (poolname, latency, total_MB, read_MB, 
        write_MB,total_IO, read_IO, write_IO,
        read_avgb, write_avgb, throttle)
    if debug:
        print 'Length of `result` tuple is %d' % int(len(result))
    return result

if __name__ == '__main__':
    node = platform.node().replace('.', '-')
    while True:
        stdin = readln()    # Expect either line from stdin or `False`
        if stdin == False:
            time.sleep(5)    # Sleep briefly
            continue

        slicedinput = stdin.rstrip('\n').split()    # list from string
        res = sliceit(slicedinput)      # res is a tuple
        timestamp = int(time.time())

        lines = [
            'system.%s.pool.%s.latency %s %d' % (node, res[0], res[1], timestamp),
            'system.%s.pool.%s.total_MB %s %d' % (node, res[0], res[2], timestamp),
            'system.%s.pool.%s.read_MB %s %d' % (node, res[0], res[3], timestamp),
            'system.%s.pool.%s.write_MB %s %d' % (node, res[0], res[4], timestamp),
            'system.%s.pool.%s.total_IO %s %d' % (node, res[0], res[5], timestamp),
            'system.%s.pool.%s.read_IO %s %d' % (node, res[0], res[6], timestamp),
            'system.%s.pool.%s.write_IO %s %d' % (node, res[0], res[7], timestamp),
            'system.%s.pool.%s.read_avgb %s %d' % (node, res[0], res[8], timestamp),
            'system.%s.pool.%s.write_avgb %s %d' % (node, res[0], res[9], timestamp),
            'system.%s.pool.%s.throttle %s %d' % (node, res[0], res[10], timestamp),
        ]
        #print lines

        message = '\n'.join(lines) + '\n'
        send_msg(message)
        time.sleep(delay)
