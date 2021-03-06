#!/bin/bash

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
if [ -f "${bin}/../conf/env.sh" ]; then
    set -a
    . "${bin}/../conf/env.sh"
    set +a
fi

APP=SVDPlusPlus
INPUT_HDFS=${DATA_HDFS}/${APP}/Input_${TYPE}
OUTPUT_HDFS=${DATA_HDFS}/${APP}/Output_${TYPE}

# either stand alone or yarn cluster
APP_MASTER=${SPARK_MASTER}

set_gendata_opt
set_run_opt

function print_config(){
get_config_values $1 $2 $3 $4 $5 $6
}

function get_config_fields(){
local report_field=$(get_report_field_name)  
echo -n "#${report_field},AppType,nExe,driverMem,exeMem,exeCore,nPar,nIter,memoryFraction,numV,mu,sigma,reset_prob"
echo -en "\n"

}
function get_config_values(){
gen_report $1 $2 $3 $4 $5 $6
echo -n ",${APP}-MLlibConfig,$nexe,$dmem,$emem,$ecore,${NUM_OF_PARTITIONS},${MAX_ITERATION},${memoryFraction},${numV},${mu},${sigma},${RESET_PROB}"
echo -en "\n"
return 0
}
