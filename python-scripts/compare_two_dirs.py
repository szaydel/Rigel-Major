base_local = '/home/szaydel/Books/'
base_remote = '/export/nfs/backups/shared/Books/'

for root, dirs, files in os.walk('/home/szaydel/Books'):
    for f in files:
        x = (os.path.split(root))
        ## print(x[1])
        print(os.path.join(base_remote,x[1],f))
        
        