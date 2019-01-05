FROM parrotstream/centos-openjdk:8

USER root

ADD cloudera-cdh5.repo /etc/yum.repos.d/
RUN rpm --import https://archive.cloudera.com/cdh5/redhat/5/x86_64/cdh/RPM-GPG-KEY-cloudera
RUN yum install -y sudo \
    hadoop-hdfs-namenode hadoop-hdfs-datanode \
    postgresql hive hive-jdbc hive-metastore \
    impala impala-server impala-shell impala-catalog impala-state-store
RUN yum clean all

RUN mkdir -p /var/run/hdfs-sockets; \
    chown hdfs.hadoop /var/run/hdfs-sockets
RUN mkdir -p /data/dn/
RUN chown hdfs.hadoop /data/dn

RUN wget https://jdbc.postgresql.org/download/postgresql-9.4.1209.jre7.jar -O /usr/lib/hive/lib/postgresql-9.4.1209.jre7.jar

RUN groupadd supergroup; \
    usermod -a -G supergroup impala; \
    usermod -a -G hdfs impala; \
    usermod -a -G supergroup hive; \
    usermod -a -G hdfs hive

WORKDIR /

ADD etc/supervisord.conf /etc/
ADD etc/core-site.xml /etc/hadoop/conf/
ADD etc/hdfs-site.xml /etc/hadoop/conf/
ADD etc/hive-site.xml /etc/hive/conf/
ADD etc/core-site.xml /etc/impala/conf/
ADD etc/hdfs-site.xml /etc/impala/conf/
ADD etc/hive-site.xml /etc/impala/conf/

# Various helper scripts
ADD bin/start-impala.sh /
ADD bin/supervisord-bootstrap.sh /
ADD bin/wait-for-it.sh /
RUN chmod +x ./*.sh

# HDFS
EXPOSE 50010 50020 50070 50075 50090 50091 50100 50105 50475 50470 8020 8485 8480 8481
EXPOSE 50030 50060 13562 10020 19888

# Hive
EXPOSE 9083

# Impala
EXPOSE 21000 21050 22000 23000 24000 25010 26000 28000

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]