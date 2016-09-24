FROM mesosphere/mesos:1.0.11.0.1-2.0.93.ubuntu1404

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos-1.0.1.so

ADD https://s3.amazonaws.com/flink-nightly/flink-1.2-SNAPSHOT-bin-hadoop2.tgz /tmp/flink.tgz
RUN tar xzf /tmp/flink.tgz -C /opt

ENV MESOS_SANDBOX /opt/flink-1.2-SNAPSHOT
WORKDIR /opt/flink-1.2-SNAPSHOT
COPY conf/ /opt/flink-1.2-SNAPSHOT/conf/

# the appmaster expects certain files to be in the sandbox directory
RUN ln -s conf/flink-conf.yaml flink-conf.yaml \
  && ln -s conf/log4j.properties log4j.properties \
  && ln -s lib/flink-dist_2.10-1.2-SNAPSHOT.jar flink.jar \
  && ln -s lib/flink-python_2.10-1.2-SNAPSHOT.jar flink-python_2.10-1.2-SNAPSHOT.jar \
  && ln -s lib/log4j-1.2.17.jar log4j-1.2.17.jar \
  && ln -s lib/slf4j-log4j12-1.7.7.jar slf4j-log4j12-1.7.7.jar

ENV _CLIENT_SHIP_FILES flink-python_2.10-1.2-SNAPSHOT.jar,log4j-1.2.17.jar,slf4j-log4j12-1.7.7.jar,log4j.properties
ENV _FLINK_CLASSPATH *

ENV _CLIENT_TM_MEMORY 1024
ENV _CLIENT_TM_COUNT 1
ENV _SLOTS 2

ENV _CLIENT_USERNAME root
ENV _CLIENT_SESSION_ID default

CMD $JAVA_HOME/bin/java -cp "*" -Dlog.file=jobmaster.log -Dlog4j.configuration=file:log4j.properties org.apache.flink.mesos.runtime.clusterframework.MesosApplicationMasterRunner --configDir .
