import re
mystr = re.compile('^\#{2}fstab\#{2}([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})', re.VERBOSE)

def extr_nfs_entry(file_l):
    new_l = []
    for each_file in file_l:
        with open(each_file, 'rt') as stream:
            for line in stream.readlines():
        ## This is where we select the hostname line, and extract IP address
        ## of the client
                if '##getent-hostname##' in line:
                    cli_IP = line.rsplit('#')[4].split(' ')[0]
                    ## print(cli_IP)
                if re.match(mystr,line):
                    ''' For each matching line, we need to do a few things
                        1) remove ##fstab## from line
                        2) Create a list containing Client IP, NFS IP, Export
                    '''
                    rewr_line = re.sub('^##fstab##','',line).split(' ')[0].split(':')
                    ## rewr_line = re.sub('^##fstab##','',line).split(' ')[0].replace(':',' ')
                    ## rewr_line = rewr_line.split(' ')[0].split(':')
                    ## rewr_line = cli_IP+' '+rewr_line
                    rewr_line.insert(0,cli_IP)
                    # print(rewr_line)
                    new_l.append(rewr_line)
                stream.close()
    return(new_l)

parsed_nfs_li = []
file_l = ['/tmp/input.file1','/tmp/input.file2']

x = extr_nfs_entry(file_l)

my_exports = []
for a in x:
    my_exports.append(a[2])
    my_exports = list(set(my_exports))

f_out = open('/tmp/output','at')
for a in my_exports:
    m = []
    l = []
    for b in x:
        if a in b:
            m.append(b[0])
            l.append(b[1])
            m,l = list(set(m)),list(set(l))
            print(len(m))
            cli_arr = ''
            count = 0
            while count < len(m):
                cli_arr += m[count]+' '
                count += 1
            #print(cli_arr)
            #print(cli_arr+' '+l[0]+' '+b[2])
''' My last attempt, which looks promising:
f_out = open('/tmp/output','at')
for a in my_exports:
    cli_arr = []
    ## Create a range which should be from 0 to length of x
    for b in range(0,len(x),1):
        ## Make sure that there are no dupes in cli_arr
        if a in x[b] and a not in cli_arr:
            cli_arr.append(x[b][0])
    f_out.write(a+'\t'+x[b][1]+'\t'+":".join(["%s" % el for el in cli_arr])+'\n')
f_out.close()
'''

'''

cli_list = []
counter = 0
while counter < len(x):
    for each_export in my_exports:
        if each_export in x[counter]:
            if x[counter][0] not in cli_list:
                cli_list.append(x[counter][0])
    counter += 1
fin_string = " ".join(["%s" % each for each in cli_list])
fin_string

    #f_out.write(a+m+l+'\n')
#f_out.close()
'''