#!/usr/bin/env bash

# HDFS

if [[ ! -e /var/lib/hadoop-hdfs/cache/hdfs/dfs/name/current ]]; then
  /etc/init.d/hadoop-hdfs-namenode init
fi
supervisorctl start hdfs-namenode
supervisorctl start hdfs-datanode

sudo -u hdfs hdfs dfsadmin -safemode wait
sudo -u hdfs hdfs dfs -mkdir -p /user/hive/warehouse
sudo -u hdfs hdfs dfs -mkdir -p /user/impala
sudo -u hdfs hdfs dfs -mkdir -p /tmp
sudo -u hdfs hdfs dfs -chmod -R 777 /

# Hive

rm /opt/hive/logs/*.pid 2> /dev/null

/wait-for-it.sh postgres:5432 -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n--------------------------------------------"
    echo -e "    PostgreSql not ready! Exiting..."
    echo -e "--------------------------------------------"
    exit $rc
fi

psql -h postgres -U postgres -c "CREATE DATABASE metastore;" 2>/dev/null

/usr/lib/hive/bin/schematool -dbType postgres -initSchema

supervisorctl start hive-metastore

# Impala

/wait-for-it.sh impala:9083 -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "     HIVE not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

supervisorctl start impala-state-store
supervisorctl start impala-catalog
supervisorctl start impala-server

/wait-for-it.sh localhost:21050 -t 120
/wait-for-it.sh localhost:24000 -t 120
/wait-for-it.sh localhost:25010 -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "     Impala not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi
