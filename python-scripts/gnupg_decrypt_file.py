#!/usr/bin/python3.1
import os, sys, getopt, gnupg
file_list = sys.argv[1:]

gpg_files_dir = 'Private'
my_home_dir = os.environ.get('HOME')
gpg_home_dir = os.path.join(my_home_dir,'.gnupg')

## Identify and store GnuPg binary in a variable
if os.path.exists('/usr/bin/gpg2'):
    gpg_bin = '/usr/bin/gpg2'
elif os.path.exists('/usr/bin/gpg'):
    gpg_bin = '/usr/bin/gpg2'
else:
    print('[Critical] Unable to locate GnuPg Binary.')
    sys.exit(1)
    
gpg = gnupg.GPG(gpgbinary='/usr/bin/gpg2', gnupghome=gpg_home_dir, verbose=False)

def does_exist(f_path):
    if os.access(f_path,os.R_OK):
        print('OK!')
        return 'OK'
    else:
        print('Not OK!')
        return'xOK'
    
for each_item in file_list:
    # Verify that file in the list exists
    if does_exist(each_item) == 'OK':
        f_in = open(each_item, 'rb')
        do_decrypt = gpg.decrypt_file(f_in,always_trust=True)
        os.system('clear'); print(do_decrypt)
    else:
        ## Check if full path is used    
        path_chk = os.path.dirname(each_item)
        ## if path_chk is empty, the filename is specified in a relative form
        if path_chk == '':
            each_item = os.path.join(my_home_dir,gpg_files_dir,each_item)
            if does_exist(each_item) == 'xOK':
                print('File', each_item,'does not exist')
                sys.exit(1)
            else:
                print('Assuming path to be:', each_item)
                print('File', each_item, 'exists!')
                print('Valid file',each_item)
                f_in = open(each_item, 'rb')
                do_decrypt = gpg.decrypt_file(f_in,always_trust=True)
                os.system('clear'); print(do_decrypt)
