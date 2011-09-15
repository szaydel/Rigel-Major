#!/usr/bin/env python
################################################################################
### If system is ubuntu, configure static network interface entry ##############
################################################################################
#: Title       : Ubuntu Server Network Interface Setup Utility
#: Date        : 2011-09-14
#: Rev. Date   : ##
#: Author      : Sam Zaydel
#: Version     : 1.1.0
#: Description : Will follow my standard logic of having a symlink to 
#:             : interfaces file, instead of actual file and link to
#:             : interfaces.static
#: Options     : -a -d -g -i -m
#: Path to file: not important, uses absolute paths, so can reside anywhere
##
################################################################################
# Define variables used in the script
# We need to make sure that we are running on a Debian-based system
from os import path as os_path
from os import rename as os_rename
from os import access as os_access
from os import W_OK as os_canwrite
from os import symlink as os_symlink
from sys import exit as system_exit
from sys import argv as system_argv

def validate_os(os_name):
    '''Function to validate that we are indeed running on expected OS.'''
    lsbdata = '/etc/lsb-release'
    ## Might as well bail here if lsb-release file is missing
    if not os_path.exists(lsbdata): return 1
    os_name = os_name.lower()
    lsbdata_d = {}
    ## Make a dictionary out of data in lsb-release file
    ## this may seem unnecessary, but may find use for it in the future
    with open('/etc/lsb-release', 'r') as info:
        lsbdata_d = { k:v for k,v in \
            [ a.strip('\n').split('=') \
            for a in info.readlines() ] }
        if lsbdata_d['DISTRIB_ID'].lower() == os_name:
            return True
        else:  
            return False

def check_ifcfg_file_exists(file_path):
    ifcfg_ = os_path.exists(file_path)
    ## Validate that path indeed exists, and return True
    ## if the path is existing, else return false
    try:
        if not ifcfg_ == True:
            retcode = False
            raise OSError(13,'File Does not exist, will Create', file_path)
        else:
            retcode = True
            raise OSError(99,'File Already exists, will Append not Overwrite', file_path)
    except OSError as e:
        print e    
    return retcode
          
def check_file_islink (file_path):
    '''Function used to check whether file is a symlink or an actual
    file. We expect to return False if file is real, else expect
    to see True returned.'''  
    if not os_path.islink(file_path):
        ## file is real and we should return False
        return False
    else:
        return True

## Assuming we have write access, we will touch the file
def touch_file(file_path):
    
    ''' Function will create a file, based on the path supplied,
    without actually writing anything to the file. We are performing
    an equivalent of Unix (touch).
    '''
    
    def write(file_path):
        ''' Function essentially opens a file in 'w' mode, and writes
        nothing but a null string to the file.
        '''
        with open(file_path, 'w') as f:
            f.write('')
            f.close()
        
    from sys import exc_info as sys_excinfo
    
    ## If the file foes not exist, we will attempt to create it
    ## and if we encounter a failure, we will raise an IOError
    
    if not os_path.exists(file_path):
        try:
            write(file_path)
        except IOError as e:
            print '%s %s\n%s' % (sys_excinfo()[1],\
                    '','Unable to create file!')
            return False
    else:
        return True

    ## If the file does exist, we need to make that we can
    ## write to the file
            
    try:
        if not os_access(file_path,os_canwrite):
            raise IOError(13,'Permission denied',file_path)
        else:
            write(file_path)
            return True
    except IOError as e:
        print '%s %s\n%s' % (sys_excinfo()[1],\
                '','Unable to modify file!')
        return False

def rename_file(file_path,new_file_path):
    from sys import exc_info as sys_excinfo
    ## We are expecting that the path will exist, since we are
    ## trying to rename it to something else, if does not exist
    ## we must raise an error
    if not os_path.exists(file_path):
        try:
            raise OSError(13,'File does not exist',file_path)
        except OSError as e:
            print e
        return False
    ## If the new filename to which we want to rename exists, we stop
    elif os_path.exists(new_file_path):
        try:
            raise OSError(99,'File already exists, cannot create',new_file_path)
        except OSError as e:
            print e
        return False
    ## If we do not get caught be either scenario above, we need to try
    ## to rename the file, using try/except method
    else:
        try:
            os_rename(file_path,new_file_path)
        except OSError as e:
            print '%s%s %s' % (e,', cannot rename', file_path)
            return False
    return True

## Start main portion of the script
if __name__ == '__main__':

    ## If we cannot validate version of the OS, we bail
    if validate_os('ubuntu') == False:
        try:
            raise Exception('Unknown Operating System', 1)
        except Exception as e:
            print '%s %s %s %d' % ('Exception Raised:', e[0], 'Return Code:',e[1])
            system_exit(e[1])

## Imports in the '__main__' section of the program
import argparse
import string
import time
cmdline_args = system_argv[1:]

## Define our main parser and add all required arguments
## gateway is the only optional argument with this script
parser = argparse.ArgumentParser(version='1.1',
                    description='''Network Interface 
                    Persistent Configuration Generator Tool''',
                    prog=system_argv[0],
                    usage='%(prog)s -i <Interface Name> -a <IP Address> -m <Subnet Mask> [-g <Gateway Address>]'
                    )
parser.add_argument('-i','--ifname',action='store',
                    dest='ifname',help='Network Interface Name',
                    default='eth0'#,required=True
                    )
parser.add_argument('-a','--addr',action='store',
                    default='192.168.10.100',dest='addr',help='IP Address'#,required=True
                    )
parser.add_argument('-m','--mask',action='store',
                    dest='mask',help='Default Subnet Mask',
                    default='255.255.252.0'#,required=True
                    )
parser.add_argument('-g','--gateway',action='store',
                    dest='gateway',help='Default Gateway Address',
                    default='192.168.10.1',required=False
                    )
parser.add_argument('-d','--debug',action='store_true',
                    help='Debugging Enabled',
                    required=False
                    )
## For simulation uncomment next line
## args = parser.parse_args(['-m255.255.255.0', '-a10.10.0.1','-ieth1'])
args = parser.parse_args()

## If the debug variable is set to 1 or True
## we will perform actions specific to debug mode
debug = args.debug

## We build a dictionary of all elements from args
## that we will insert as variables into the template
l_args = [args.ifname, args.addr, args.mask, args.gateway]
time_stamp = time.strftime('%A %b %d, %H:%M:%S %Y', time.strptime(time.ctime()))
confDict = {'ifname':    l_args[0],
            'addr':      l_args[1],
            'mask':      l_args[2],
            'gateway':   l_args[3],
            'time_stamp': time_stamp
            }

values = confDict

## The dictionary which we just created 'values'
## will now be fed into the string.Template
t = string.Template(
"""# Network interface $ifname added with Interface Conf Generator
# Entry Added on: $time_stamp 
auto $ifname
    iface $ifname inet static
    address $addr
    netmask $mask
    gateway $gateway

""")
template = t.substitute(values)

## We need to define a number of variables specifically
## those of paths to the different ifconfig files
if debug:
    ifcfg_dir = '/tmp'
else:
    ifcfg_dir = '/etc/network'
static_interfaces = 'interfaces.static'
def_interfaces = 'interfaces'
new_def_interfaces = 'dist.interfaces'
static_interfaces_path = os_path.join(ifcfg_dir,static_interfaces)
def_interfaces_path = os_path.join(ifcfg_dir,def_interfaces)
new_def_interfaces_path = os_path.join(ifcfg_dir,new_def_interfaces)

## If the 'interfaces.static' file does not exist, we need
## to create it, since we will write new config to it
## and we will symlink it via /etc/network/interfaces
if not check_ifcfg_file_exists(static_interfaces_path):
    x = touch_file(static_interfaces_path)
    ## If we cannot successfully create 'interfaces.static' file
    ## we need to bail here
    if x == False:
        system_exit(1)
    ## Assuming we got this far, we can now write our pre-defined template
    ## to the 'interfaces.static' file
    with open(static_interfaces_path, 'wt') as f:
        f.write(template)
if check_ifcfg_file_exists(def_interfaces_path) and not check_file_islink(def_interfaces_path):
    x = rename_file(def_interfaces_path,new_def_interfaces_path)
    if not x:
        print '%s %s' % ('Failed with rename operation of',def_interfaces_path)
        system_exit(1)
    ## Create a symlink from /etc/network/interfaces.static to /etc/network/interfaces
    x = os_symlink(static_interfaces_path,def_interfaces_path)
else:
    ## If the default 'interfaces' file already exists as a symlink,
    ## we will make sure to open with 'at', since we are modifying
    ## an already existing interfaces file with potentially active
    ## network interfaces
    x = check_file_islink(def_interfaces_path)
    if x == True:
        with open(def_interfaces_path, 'at') as f:
            f.write(template)