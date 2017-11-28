#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

echo "========== running ${APP} benchmark =========="

exp_type=$1
exp_no=$2
# path check
DU ${INPUT_HDFS} SIZE 

#JAR="${DIR}/target/scala-2.10/pagerankapp_2.10-1.0.jar"
JAR="${DIR}/target/PageRankApp-1.0.jar"
CLASS="src.main.scala.SimplePageRank"
OPTION="${INOUT_SCHEME}${INPUT_HDFS} ${INOUT_SCHEME}${OUTPUT_HDFS} ${NUM_OF_PARTITIONS} ${MAX_ITERATION} ${TOLERANCE} ${RESET_PROB} ${STORAGE_LEVEL}"

# echo "start to execute iostat"
# sh +x iostat_execute.sh "dm-2" ${APP}_${TYPE}_${EXEMEM} &
# ssh spark2 "sh +x iostat_execute.sh \"dm-2\" ${APP}_${TYPE}_${EXEMEM} &"&

setup
for((i=0;i<${NUM_TRIALS};i++)); do
	echo "${OPTION}"
	RM ${OUTPUT_HDFS}
	purge_data "${MC_LIST}"	
	START_TS=`get_start_ts`;
	START_TIME=`timestamp`
	START_SEC=`get_second`
	echo_and_run sh -c " ${SPARK_HOME}/bin/spark-submit --class $CLASS ${YARN_OPT} ${SPARK_OPT} ${SPARK_RUN_OPT} $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/${APP}_run_${START_TS}.dat"
res=$?;
	END_TIME=`timestamp`
	END_SEC=`get_second`
	duration_sec=`expr $END_SEC - $START_SEC`
    echo "${APP}:$duration_sec" >>  "$DURATION_LOG_PATH/exp_${exp_type}_${exp_no}.log"
get_config_fields >> ${BENCH_REPORT}
print_config  ${APP} ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} ${res}>> ${BENCH_REPORT};
done
# iostat_stop.sh ${APP}
# ssh spark2 "iostat_stop.sh ${APP}"
# mv /home/hadoop/bryantchang/platforms/logs/spark/spark.log /home/hadoop/bryantchang/platforms/logs/spark/${APP}_${TYPE}_${EXEMEM}_master.log
# ssh spark2 "mv /home/hadoop/bryantchang/platforms/logs/spark/spark.log /home/hadoop/bryantchang/platforms/logs/spark/${APP}_${TYPE}_${EXEMEM}.log"
teardown
exit 0


