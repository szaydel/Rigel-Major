#!/usr/bin/env python

blocksize_kb = 4
def kbyte_to_byte(kb):
    byte = kb * 1024
    return byte
def gbyte_to_byte(gb):
    byte = gb * pow(1024,3)
    return byte
def arc_size(blk):
    arc_sz = blk * 200
    print 'arc_sz', arc_sz
    if arc_sz <= 10000000:
        arc_sz = float(arc_sz / 1024)
        return(arc_sz,'kb' ) 
    elif arc_sz <= 1000000000:
        arc_sz = float(arc_sz / pow(1024,2))
        return(arc_sz,'mb' )
    elif arc_sz >= 1000000000:
        arc_sz = float(arc_sz / pow(1024,3))
        return (arc_sz, 'gb')


blocks = gbyte_to_byte(20) / kbyte_to_byte(4)
