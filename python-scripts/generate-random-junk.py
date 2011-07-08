#!/usr/bin/env python
################################################################################
### Script used for generation of fixed-size files for various testing #########
################################################################################
#: Title       : Generate fixed-size files using /dev/urandom
#: Date        : 2011-05-25
#: Rev. Date   : ##
#: Author      : Sam Zaydel
#: Version     : 0.1.0
#: Description : Using data from /dev/urandom we generate a bunch of files
#:             : writing the same 1024 bytes over and over
#: Options     : Using optparse, try -h argument to see all available options
#: Path to file: not-defined
##
import sys
import tempfile
from datetime import datetime
from os import urandom
from os import path
from os import access
from os import W_OK
import optparse

## Gather arguments and store as necessary for further assignment
parser = optparse.OptionParser(description= \
                'Generate random files of fixed size using random bytes from /dev/urandom',\
                usage='%prog [ -h --help -c --count -s --size-of-tmpfile -w --work-dir ]')

## Define total count of files to be written, use in opts.filecount
parser.add_option('-c','--count',\
                  help='Define number of files to be created',\
                  action='store',\
                  type='int',\
                  dest='filecount')

## Define path to working directory here, use in opts.workingdir
parser.add_option('-w','--work-dir',\
                  help='Root directory where temporary data files are to be created',\
                  action='store',\
                  type='string',\
                  dest='workingdir')

## Define size of files to be created here, use in opts.filesize
parser.add_option('-s','--size-of-tmpfile',\
                  help='Set the size of every individual file being created, defaults to 100K',\
                  action='store',\
                  type='int',\
                  dest='filesize')

if len(sys.argv[:]) <= 1:
    parser.print_usage()
    sys.exit(1)
    
opts,args = parser.parse_args()
#instances = opts.instances
#delay = opts.delay
#logfile = opts.logfile

if opts.workingdir == None:
## Asuming a default of '/tmp'
    work_dir = '/tmp'
## Do we have access to where we are trying to write data?
elif access(opts.workingdir, W_OK):    
    work_dir = opts.workingdir
else:
    print 'Unable to write to %s because: %s' % (ops.workingdir,'Permission Denied')
    sys.exit(1)

if opts.filesize == None:
    filesize = 100
else:
    filesize = opts.filesize

if opts.filecount == None:
    count = 1
else:
    count = opts.filecount
    
''' Just some area to add information to the script.
'''

# work_dir = '/data/tmp_2'
record_block = 1024
pre = datetime.now().strftime("%Y%m%d%H%M%S-")
tmp_dir = tempfile.mkdtemp(prefix=pre,dir=work_dir)
rand_bytes = urandom(record_block)
# total_cout_of_files = 10

## Size should be specified in Kilobytes
## i.e. 10K, 100K, 100K, etc.
def create_file(filename,filesize):
    create_file_counter = 1
    while create_file_counter <= filesize:
        filename.write(rand_bytes)
        create_file_counter += 1   
    filename.flush()
    filename.close()
    return(filename.name)
    
def create_all_files(count):
    ## We are specifying filesize in kilobytes here
    ## filesize = '' << Already defined above
    create_all_files_counter = 1
    for a in range(1,count+1,1):
        filepre = 'seq-'+str(a)+'-'
        tempf = tempfile.NamedTemporaryFile(mode='w+b' \
                ,prefix=filepre,dir=tmp_dir,delete=False)
        a = create_file(tempf,filesize)
        print 'Created file: %s, Size is: %dKB' % (a,filesize)

create_all_files(count)
