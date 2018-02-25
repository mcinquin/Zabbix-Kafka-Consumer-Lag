#!/bin/bash
###
# Version  Date      Author    Description
#-----------------------------------------------
# 0.1      22/02/18  Shini31   Initial version
#
###


#Global Variables
VERSION="0.1"
PROGNAME=`basename $0`
PROGPATH=`dirname $0`
KAFKA_CG_PATH="/usr/local/kafka"
KAFKA_HOST="127.0.0.1"
KAFKA_PORT="9092"
CONFIG_FILE=""
CG=""

#Help function
print_help() {
  echo "This zabbix script can discovery all consumer groups in a Kafka server and calculate the global lag for a specific consumer group"
  echo "Usage: $PROGNAME"
  echo "    -H (--host)      <host>  Hostname or IP address of Kafka server"
  echo "    -P (--port)      <port>  Port of Kafka server"
  echo "    -C (--config)    <config_file> Configuration parameters file (with jaas if needed)"
  echo "    -G (--group)     <consumer_group> Name of the consumer group for lag"
  echo "    -d (--discovery) List all the consumer group for zabbix discovery"
  echo "    -l (--lag)       Calculate the global lag for a specific consumer group"
  echo "    -v (--version)   Script version"
  echo "    -h (--help)      Script usage"
}

#Check presence of required parameter's number
if [ "$#" -lt 3 ]; then
  echo "PROGNAME: requires at least three parameters"
  print_help
  exit 1
fi

#Getting Parameters options
OPTS=$(getopt -o C:G:H:P:dghlv -l host:,port:,config:,discovery,group:,help,lag,version -n "$(basename $0)" -- "$@")
eval set -- "$OPTS"
while true
do
  case $1 in
    -H|--host)
      KAFKA_HOST="$2"
      shift 2
      ;;
    -P|--port)
      KAFKA_PORT="$2"
      shift 2
      ;;
    -C|--config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    -G|--group)
      CG="$2"
      shift 2
      ;;
    -d|--discovery)
      CG_DISCOVERY="true"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    -l|--lag)
      CG_LAG="true"
      shift
      ;;
    -v|--version)
      print_version
      exit 0
      ;;
    --)
      shift ; break
      ;;
    *)
      echo "Unknown argument: $1"
      print_help
      exit 1
      ;;
  esac
done


if [ "$CG_LAG" ] && [ "$CG" == "" ]; then
  echo "Consumer group must to be declare."
  exit 1
fi

#Zabbix's discovery
if [ "$CG_DISCOVERY" ]; then
  CG_LIST=`${KAFKA_CG_PATH}/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_HOST}:${KAFKA_PORT} --command-config ${CONFIG_FILE} --list`
  ZBX_DISCO_LIST=`for i in ${CG_LIST}; do echo -en "{"; echo -en "\"{#CONSUMER_GROUP}\":\"$i\""; echo -en "},"; done`
  ZBX_DISCO_LIST=${ZBX_DISCO_LIST%?};
  echo -e "{\"data\":[${ZBX_DISCO_LIST}]}"
fi


#Consumer group lag
if [ "$CG_LAG" ]; then
	${KAFKA_CG_PATH}/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_HOST}:${KAFKA_PORT} --command-config ${CONFIG_FILE} --describe --group ${CG} |tail -n +3 |awk '{sum+=$5} END {print sum}'
fi
