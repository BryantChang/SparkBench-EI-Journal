#!/bin/bash

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
if [ -f "${bin}/../conf/env.sh" ]; then
  set -a
  . "${bin}/../conf/env.sh"
  set +a
fi

APP=sql
APP_DIR=${DATA_HDFS}/${APP}
INPUT_HDFS=${DATA_HDFS}/${APP}/Input_${TYPE}
OUTPUT_HDFS=${DATA_HDFS}/${APP}/Output_${TYPE}

# either stand alone or yarn cluster
APP_MASTER=${SPARK_MASTER}
STORAGE_LEVEL="MEMORY_AND_DISK"
set_gendata_opt
set_run_opt

function print_config(){
               get_config_values $1 $2 $3 $4 $5 $6
}

function get_config_fields(){
   local report_field=$(get_report_field_name)  
    echo -n "#${report_field},AppType,nExe,driverMem,exeMem,exeCore"
     echo -en "\n"
                    
}
function get_config_values(){
      gen_report $1 $2 $3 $4 $5 $6
      echo -n ",${APP}-config,$nexe,$dmem,$emem,$ecore"
       echo -en "\n"
       return 0
}
