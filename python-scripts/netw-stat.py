#!/usr/bin/env python3.1
def collector(x,y):
    d = {}
    for a in y:
        f = open('/sys/class/net/'+x+'/statistics/'+a)
        b = f.read().strip('\n')
        f.close()
        d[a] = b
    return d


init_stats = {'rx_bytes': '0','tx_bytes':'0','rx_errors':'0','tx_errors':'0'}
eth_adapter = 'wlan0'
keystats = ('rx_bytes','tx_bytes','rx_errors','tx_errors')
count = 0
last_stats = init_stats
new_stats = {}
diff = {}    
while count < 15:
    x = collector(eth_adapter,keystats)
    if last_stats == init_stats:
        print(last_stats)
        last_stats = x
    else:
        for a in x.keys():
            diff[a] = (int(x.get(a)) / 1024) - (int(last_stats.get(a)) / 1024)
            last_stats[a] = int(x.get(a))
        print(diff)
    count += 1
    sleep(1)