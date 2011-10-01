#!/usr/bin/env python
import NZA
from NZA import nms_connect
a = nms_connect(host='localhost')

## Create a ZVOL:
b = a.zvol.create('lab3_pool_a/zvol_a1', '1G', '8K', '1')
## Destroy ZVOL:
b = a.zvol.destroy('lab3_pool_a/zvol_e', '-r')
b = a.zvol.create_with_props('lab3_pool_a/zvol_e', '1GB','8K', 1, \
	{':important':'Yes','checksum':'off','copies':'2'})
## Get list of all ZVOLs
b = a.zvol.get_names('')
## Return list of available ZVOLs, indexed
for i in b:
    print '[%d] %s' % (ind, i)
    ind += 1

## Appliance properties
appl_props = a.appliance.get_props('')
nms_props = a.server.get_props('')
nms_props['saved_configroot']
c = a.server.set_prop('saved_configroot', '.config_cu')

## LUN Properties
b = a.volume.get_child_props('c1t9d0', '')
p = a.lun.get_child_props('c1t9d0','device_id')

## List of all LUNs
for i in a.volume.get_luns_for_all_volumes():
    print i

## Get device ID for all LUNs
for i in a.volume.get_luns_for_all_volumes():
    p = a.lun.get_child_props(i,'device_id')
    print p['device_id']

## Connect to appliance
nms_inst = nms_connect(host='localhost')

## Get information about checkpoints
a = nms_inst.syspool.get_rootfs_names()
for i in range(0,len(a),1):
    print a[i]

rootfs_getprops = nms_inst.syspool.get_rootfs_props('syspool/rootfs-nmu-006','')

## Return memory information
for i in raminfo.keys():
    print '%s :: %sMB' % (i,raminfo[i])