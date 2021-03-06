#!/bin/bash
bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"

echo "========== running ${APP} bench =========="


exp_type=$1
exp_no=$2
# pre-running
DU ${INPUT_HDFS} SIZE 

JAR="${DIR}/target/KMeansApp-1.0.jar"
CLASS="kmeans_min.src.main.scala.SimpleKMeans"
OPTION=" ${INPUT_HDFS} ${OUTPUT_HDFS} ${NUM_OF_CLUSTERS} ${MAX_ITERATION} ${STORAGE_LEVEL} ${NUM_OF_PARTITIONS}"
echo $OPTION
if  [ $# -ge 1 ] && [ $1 = "graphx" ]; then

	APP=KMeans
	CLASS="KmeansApp"
	OPTION=" ${INOUT_SCHEME}${INPUT_HDFS} ${INOUT_SCHEME}${OUTPUT_HDFS} ${NUM_OF_CLUSTERS} ${MAX_ITERATION} ${NUM_RUN}"
fi

echo "start to execute iostat"

# sh +x iostat_execute.sh "dm-2" ${APP}_${TYPE}_${EXEMEM} &
# ssh spark2 "sh +x iostat_execute.sh \"dm-2\" ${APP}_${TYPE}_${EXEMEM} &"&

setup

for((i=0;i<${NUM_TRIALS};i++)); do
    RM ${OUTPUT_HDFS}
    # (Optional procedure): free page cache, dentries and inodes.
    # purge_data "${MC_LIST}"
    START_TS=`get_start_ts`;
    START_TIME=`timestamp`
    START_SEC=`get_second`

    echo_and_run sh -c " ${SPARK_HOME}/bin/spark-submit --class $CLASS --master ${APP_MASTER} ${YARN_OPT} ${SPARK_OPT} ${SPARK_RUN_OPT} $JAR ${OPTION} 2>&1|tee ${BENCH_NUM}/${APP}_run_${START_TS}.dat"
    res=$?;

    END_TIME=`timestamp`
    END_SEC=`get_second`
	duration_sec=`expr $END_SEC - $START_SEC`
    echo "${APP}:$duration_sec" >>  "$DURATION_LOG_PATH/${exp_type}/exp_${exp_no}.log"
    get_config_fields >> ${BENCH_REPORT}
    print_config  ${APP} ${START_TIME} ${END_TIME} ${SIZE} ${START_TS} ${res}>> ${BENCH_REPORT};
done
# iostat_stop.sh ${APP}
# ssh spark2 "iostat_stop.sh ${APP}"
# ssh spark2 "mv /home/hadoop/bryantchang/platforms/logs/spark/spark.log /home/hadoop/bryantchang/platforms/logs/spark/${APP}_${TYPE}_${EXEMEM}.log"
teardown

exit 0

