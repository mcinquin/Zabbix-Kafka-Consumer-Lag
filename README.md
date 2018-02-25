# Zabbix-Kafka-Consumer-Lag


## Review
This Zabbix script checks kafka's consumer lag and can discover all the consumer groups connected to a Kafka server.

## Requirements
Kafka, Zabbix' agent

## Installation
* Download the script on the kafka server
* Create the following directory: /etc/zabbix/externalscripts
* Move the script in this directory
* Change the following variables in the script:
  * KAFKA_CG_PATH: Path to kafka-consumer-groups.sh script
  * KAFKA_HOST: IP or DNS of kafka server
  * KAFKA_PORT: Kafka's port
  * CONFIG_FILE: path to consumer properties and jaas configuration file (consumer and jaas configuration need to be in the same file)
* Create a userparameter file for the zabbix agent with theses following lines
```
#Discover all the consumer groups
UserParameter=kcg.discovery,/etc/zabbix/externalscripts/kcg.sh -H <kafka ip or dns> -P <kafka port> -C <path to consumers properties file> -d
#Check lag for a specific consumer group
UserParameter=kcg.lag[*],/etc/zabbix/externalscripts/kcg.sh -H <kafka ip or dns> -P <kafka port> -C <path to consumers properties> -l -G $1
```
* Create a discovery rule in Zabbix:
```
key: kcg.discovery
```
* Create a item prototype
```
key: kcg.lag[{#CONSUMER_GROUP}]
```



## Usage
```
This zabbix script can discovery all consumer groups in a Kafka server and calculate the global lag for a specific consumer group
Usage: kcg.sh
    -H (--host)      <host>  Hostname or IP address of Kafka server
    -P (--port)      <port>  Port of Kafka server
    -C (--config)    <config_file> Configuration parameters file (with jaas if needed)
    -G (--group)     <consumer_group> Name of the consumer group for lag
    -d (--discovery) List all the consumer group for zabbix discovery
    -l (--lag)       Calculate the global lag for a specific consumer group
    -v (--version)   Script version
    -h (--help)      Script usage
```
