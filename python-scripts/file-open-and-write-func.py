#!/usr/bin/python3.1
#
#
#
#
#
def foo (x):
    print('argument is', x)
    f = open('/tmp/log.file', 'a')
    if isinstance(x, str):
        f.write('%s\n' % x)
    else:
        f.write('%s\n' % str(x))
    f.close()