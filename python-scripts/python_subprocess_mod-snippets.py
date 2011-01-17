#!/usr/bin/python3.1
################################################################################
### Strictly subprocess module snippets
################################################################################
x = subprocess.Popen(['/bin/ls','/ddd'], \
    stdout=subprocess.PIPE,stderr=subprocess.PIPE)
with open('/tmp/errorlog','wb') as f:
    f.write(x.stderr.read())
    f.close()