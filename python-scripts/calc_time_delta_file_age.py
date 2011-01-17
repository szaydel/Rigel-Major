#!/usr/bin/python3.1
## Calculate time delta between current time
## and timestamp of a file, remove file if
## it is more than XXX seconds old
import os, time
time_now = int(time.time())
x = int(os.path.getctime('/tmp/file_t3'))
if x + 120 > time_now:
    print('Time diff is:',(time_now - x), 'sec: OK')
else:
    print('Time diff is:',(time_now -x), 'sec: Not OK')