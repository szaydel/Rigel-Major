#!/usr/bin/bash
#
# (The MIT License)
# Copyright (c) 2012 Sam Zaydel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#: Title       : vdbench workload execution script
#: Date        : 2012-05-10
#: Author      : "Sam Zaydel" 
#: Email       : <szaydel@gmail.com>
#: Version     : 1.0
#: Description : Pulls together several bits needed to run a vdbench profile.
#:             : At the end of the run, generates a parsed file that is ready
#:             : to be processed by a Python Graphite client.
#: Options     : None
#
PATH=/usr/sbin:/usr/bin:/usr/local/bin
PROTOTYPE=prototype_4k_fs.sd
ARCSTATS_TMP=before.$$.arcstats
DATE=$(date +%Y%m%d%H%M%S)
vdb_cmd=/opt/vdb503/vdbench.bash
debug=1
create_archive=1

## Path to filesystem location where vdbench will be running
DIRECTORY=$1
if [ -z "${DIRECTORY}" ]; then
        echo "[CRIT] Please, specify a filesystem path for vdbench to use."
        exit 1
fi

if [ ! -d "${DIRECTORY}" ]; then
        echo "[CRIT] Specified filesystem path ${DIRECTORY} not found"
        exit 1
fi

function run_vdbench() {
    local output_dir=$1
    local parameter_file=$2
    ${vdb_cmd} -d27 -o ${output_dir} -f ${parameter_file}
    return $?
}

function parse_vdbench_flat() {
    local vdb_parse_cmd="${vdb_cmd} parse"
    local flatfile_inp=$1
    local flatfile_outp_tmp=$2
    local flatfile_outp_fin=${flatfile_outp_tmp/tmp/parsed}

    [[ ${debug} -eq "1" ]] && printf "Work files: %s %s %s\n"\
     "${flatfile_inp}" "${flatfile_outp_tmp}" "${flatfile_outp_fin}"

    if [[ ! -f ${flatfile_inp} ]]; then
        echo "Input file is missing. Please, fix."
        return 1
    fi

    ${vdb_parse_cmd} -i ${flatfile_inp} -o ${flatfile_outp_tmp} -c \
    "tod" \
    "Run" \
    "Xfersize" \
    "MB/sec" \
    "Read_rate" \
    "Read_resp" \
    "Write_rate" \
    "Write_resp" \
    "MB_read" \
    "MB_write" \
    "ks_rate" \
    "ks_resp" \
    "ks_wait" \
    "ks_svct" \
    "ks_avwait" \
    "ks_avact" \
    "cpu_used" \
    "cpu_user" \
    "cpu_kernel" \
    "cpu_wait" \
    "cpu_idle"

    while read -r i; do arr1=( $(for f in ${i//,/$'\n'}; do echo $f; done) ); \
    dt=$(date --utc --date "${arr1[0]}" +%s); echo ${dt} ${arr1[@]:1:20}; \
    done <${flatfile_outp_tmp} >> ${flatfile_outp_fin}

    rm -f ${flatfile_outp_tmp}      # temp file is no longer necessary, remove
}

kstat -p zfs:0:arcstats > ${ARCSTATS_TMP}
BDIR=$(basename "${DIRECTORY}")
OUTDIR=4k_fs-${BDIR}.char
PARMFILE=${BDIR}.sd

# Update parmfile with contents of the prototype file, replacing # word
# DIRECTORY with actual directory path where vdbench is going to be operating.



sed -e "s,DIRECTORY,${DIRECTORY}," "${PROTOTYPE}" > "${PARMFILE}"

run_vdbench "${OUTDIR}" "${PARMFILE}"
ret_code=$?

if [[ "${ret_code}" -ne "0" ]]; then
    printf "%s\n" "[CRIT] vdbench returned unexpected return code: ${ret_code}."
    exit 1
fi

# Run the function to parse vdbench output into format that we could use with
# graphite, one more step is the piping of data from the parsed file into
# graphite. At the moment this task is done with another script written in
# Python. 

parse_vdbench_flat "${OUTDIR}/flatfile.html" "${OUTDIR}/${PARMFILE/.sd}.${DATE}.tmp" 
ret_code=$?

if [[ "${ret_code}" -ne "0" ]]; then
    exit 1
fi

MOUNT_DEV=$(df "${DIRECTORY}" | sed -e "s,^.*(,,;s,).*$,,")
mount -v | grep -w ^${MOUNT_DEV} > ${OUTDIR}/mount
mv ${ARCSTATS_TMP} ${OUTDIR}/before.arcstats
kstat -p zfs:0:arcstats > ${OUTDIR}/after.arcstats

if [[ "${create_archive}" -ne "0" ]]; then 
    tar czf ${BDIR}.${DATE}.tgz "${OUTDIR}"
    printf "%s\n" "Archive of this run created: ${BDIR}.${DATE}.tgz"
fi

