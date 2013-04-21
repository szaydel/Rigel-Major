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
###############################################################################
# =========================================================================== #
#:.Title.......: vdbench workload execution script
#:.Date........: 2012-07-09
#:.Author......: "Sam Zaydel" 
#:.Email.......: <szaydel@racktopsystems.com>
#:.Version.....: 1.0.9
#:.Description.: 
# Script is inspired and borrows some of the bits from Richard Elling's original
# version, which was less generic and explicitly defined most parameters, with 
# only parameter expected being a directory path for vdbench to operate in. 
# In this version we pull together bits via the command line, generalizing the 
# script and reducing need for multiple scripts to run various different 
# workloads. At the end of the run, generates a parsed file that is ready to be 
# processed by a Python Graphite client.
# =========================================================================== #
#:.Options.....: `d` => Directory path for vdbench to operate in 
#:.............: `k` => Enable or disable arcstats from kstat collection
#:.............: `p` => Path to the prototype file to use for this run
#:.............: `v` => Enable debug options, makes this more verbose
# =========================================================================== #
###############################################################################

PATH=/usr/sbin:/usr/bin:/usr/local/bin
PROTOTYPE=""
ARCSTATS_TMP=before.$$.arcstats
DATE=$(date +%Y%m%d%H%M%S)
VDBENCH_SIM=/root/vdbench.simulate

if [[ -n ${VDBENCH} ]]; then
    vdb_cmd=${VDBENCH}
elif [[ -x /opt/vdb503/vdbench.bash ]]; then 
    vdb_cmd=/opt/vdb503/vdbench.bash
elif [[ -x /racktop/opt/vdb503/vdbench.bash ]]; then
    vdb_cmd=/racktop/opt/vdb503/vdbench.bash
else
    printf "%s\n" "Unable to locate vdbench binaries, exiting with status 1."
    exit 1
fi

## Default values
## Check for exported env variable
if [[ -f ${VDBENCH_SIM} ]]; then
    simulate=1
else
    simulate=0
fi

debug=0
create_archive=1
kstat_collect=0
script_name=${0##*/} ## Get the name of the script without its path


if [[ ${#@} -lt "2" ]]; then

    printf "%s\n" \
    "[Error] Minimum of two arguments are required, path and prototype." \
    "Usage: ${script_name} -d /path/to/vdbench/scratch/dir -p ./parameter.file"
    exit 1
fi

## List of options the program will accept;
## those options that take arguments are followed by a colon
optstring=k:d:p:v

## The loop calls getopts until there are no more options on the command line
## Each option is stored in $opt, any option arguments are stored in OPTARG
while getopts "${optstring}" opt
do
    case $opt in
        d) DIRECTORY="${OPTARG}"
            ;; ## $OPTARG contains the argument to the option

        k) KSTAT="${OPTARG}"
            if [[ -z "${KSTAT}"  ]]; then
                kstat_collect=0
            elif [[ "${KSTAT}" = ["Yy"] ]]; then
                kstat_collect=1
            fi
            ;;
        p) PROTOTYPE="${OPTARG}"
            ## Directory where prototype and char files are located
            CONFDIR=$(dirname ${PROTOTYPE})
            P=$(basename ${PROTOTYPE})
            PROTOTYPE_NAME=${P//.*}
            ;; ## This is the prototype file which we will be using

        v) debug=$(( $debug + 1 )) 
            ;;
        *) printf "%s\n" "[ERROR] One or more options or arguments were unexpected. Please check!"
            exit 1 ;;
   esac
done

## Remove options from the command line
## $OPTIND points to the next, unparsed argument
shift "$(( $OPTIND - 1 ))"

## Check whether a path actually exists
if [[ -d "${DIRECTORY}" ]]; then

    if [[ "${debug}" -gt "0" ]]; then
        printf "[Info] set directory path for vdbench to %s.\n" "${DIRECTORY}"
    fi

else

    if [[ "${debug}" -gt "0" ]]; then
       printf "[Error] unable to locate working directory: %s.\n" "${DIRECTORY}" >&2
    fi
    exit 1
fi

## Check whether file exists
if [[ -f "${PROTOTYPE}" ]]; then

   if [[ "${debug}" -gt "0" ]]; then
      printf "[Info] Prototype file %s selected.\n" "${PROTOTYPE}"
   fi

else

   if [[ "${debug}" -gt "0" ]]; then
      printf "[Error] unable to locate prototype file: %s.\n" "${PROTOTYPE}" >&2
   fi
   exit 2
fi

[[ ${debug} -gt "0" ]] && set -x

BDIR=$(basename "${DIRECTORY}")
OUTDIR=${HOME}/${DATE}.char
PARMFILE=${OUTDIR}/${PROTOTYPE_NAME}.parameter
CONFDIR=${CONFDIR:-$PWD}

## Let's create our Output directory now
mkdir ${OUTDIR}

[[ ${debug} -gt "0" ]] && set +x

function run_vdbench() {

    local output_dir=$1
    local parameter_file=$2

    if [[ "${debug}" -gt "0" ]]; then
        printf "[Info] switching to directory: %s.\n" "${CONFDIR}"
    fi

    ## Configuration files use relative pathing, so to make things easier, we
    ## switch to the directory where configuration files reside
    cd ${CONFDIR}

    [[ ${debug} -gt "0" ]] && set -x

    if [[ ${simulate} -eq "1" ]]; then
        ## Only do a simulated run
        printf "Running vdbench simulation with Output Dir: %s, param: %s\n\n" ${output_dir} ${parameter_file}
        ${vdb_cmd} -s -d27 -o ${output_dir} -f ${parameter_file}
    else
        printf "Running vdbench with Output Dir: %s, param: %s\n\n" ${output_dir} ${parameter_file}
        ${vdb_cmd} -d27 -o ${output_dir} -f ${parameter_file}
    fi

    [[ ${debug} -gt "0" ]] && set +x
    
    return $?
}

function parse_vdbench_flat() {

    local vdb_parse_cmd="${vdb_cmd} parse"
    local flatfile_inp=$1
    local flatfile_outp_tmp=$2
    local flatfile_outp_fin=${flatfile_outp_tmp//.tmp}

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
    dt=$(date --date "${arr1[0]}" +%s); echo ${dt} ${arr1[@]:1:20}; \
    done <${flatfile_outp_tmp} >> ${flatfile_outp_fin}

    rm -f ${flatfile_outp_tmp}      # temp file is no longer necessary, remove
}

if [[ "${kstat_collect}" -ne "0" ]]; then
    kstat -p zfs:0:arcstats > ${OUTDIR}/before.arcstats
fi

# Update parmfile with contents of the prototype file, replacing # word
# DIRECTORY with actual directory path where vdbench is going to be operating.


sed -e "s,DIRECTORY,${DIRECTORY}," "${PROTOTYPE}" > "${PARMFILE}"

run_vdbench "${OUTDIR}" "${PARMFILE}"; ret_code=$?

if [[ "${ret_code}" -ne "0" ]]; then
    printf "%s\n" "[WARN] vdbench returned unexpected return code: ${ret_code}."
fi

# Run the function to parse vdbench output into format that we could use with
# graphite, one more step is the piping of data from the parsed file into
# graphite. At the moment this task is done with another script written in
# Python. 

parse_vdbench_flat "${OUTDIR}/flatfile.html" "${OUTDIR}/graphite.${DATE}.tmp" 
ret_code=$?

if [[ "${ret_code}" -ne "0" ]]; then
    printf "%s\n" "[WARN] vdbench parsing returned unexpected return code: ${ret_code}."
fi

MOUNT_DEV=$(df "${DIRECTORY}" | sed -e "s,^.*(,,;s,).*$,,")
mount -v | grep -w ^${MOUNT_DEV} > ${OUTDIR}/mount

if [[ "${kstat_collect}" -ne "0" ]]; then
    mv ${ARCSTATS_TMP} ${OUTDIR}/before.arcstats
    kstat -p zfs:0:arcstats > ${OUTDIR}/after.arcstats
fi


if [[ "${create_archive}" -ne "0" ]]; then 
    tar czf ${OUTDIR}/$$.${DATE}.tgz "${OUTDIR}"
    printf "%s\n" "Archive of this run created: ${OUTDIR}/$$.${DATE}.tgz"
fi
