#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
DIR=`cd $bin/../; pwd`
. "${DIR}/../bin/config.sh"
. "${DIR}/bin/config.sh"
echo "========== running MF benchmark =========="

exp_type=$1
exp_no=$2


DU ${INPUT_HDFS} SIZE 


CLASS="MatrixFactorization.src.main.java.MFApp"
OPTION="${INPUT_HDFS} ${OUTPUT_HDFS} ${rank} ${MAX_ITERATION} ${LAMBDA} ${STORAGE_LEVEL}"
echo $OPTION
JAR="${DIR}/target/MFApp-1.0.jar"

#CLASS="src.main.scala.MFMovieLens"
#OPTION=" ${INOUT_SCHEME}${INPUT_HDFS} ${DATASET_DIR}/ml-10M100K/personalRatings.txt"
#OPTION=" ${INOUT_SCHEME}${INPUT_HDFS} ${DATASET_DIR}/BigDataGeneratorSuite/Graph_datagen/personalRatings.txt $NUM_OF_PARTITIONS"

setup
for((i=0;i<${NUM_TRIALS};i++)); do		
    # path check
    RM ${OUTPUT_HDFS}
    purge_data "${MC_LIST}"	
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
teardown
exit 0


