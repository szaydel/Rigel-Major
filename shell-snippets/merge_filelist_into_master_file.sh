#!/bin/bash
MERGERECORDFILE=/tmp/fin.$(date +%m%d%y)
RECORDFILELIST=/tmp/f.list
while read RECORDFILENAME
    do
        sed s/$/$(basename ${RECORDFILENAME})/g \
        ${RECORDFILENAME} >> ${MERGERECORDFILE}
    done < ${RECORDFILELIST}