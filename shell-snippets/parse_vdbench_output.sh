#!/usr/bin/bash
#
#
#
#
vdb_cmd="/opt/vdb503/vdbench.bash parse"
var_input=$1
var_output_init=$2
var_output_fin=$2.fixed
if [[ ! -f ${var_input} ]]; then
    echo "Input file is missing. Please, fix."
    exit 1
fi

 ${vdb_cmd} -i ${var_input} -o ${var_output_init} -c \
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

while read -r i; do arr1=( $(for f in ${i//,/$'\n'}; do echo $f; done) ); dt=$(date --utc --date "${arr1[0]}" +%s); echo ${dt} ${arr1[@]:1:20}; done <${var_output_init} >> ${var_output_fin}
