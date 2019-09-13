FROM openjdk:8-jre-alpine

RUN apk --no-cache add curl

ARG JMETER_VERSION=5.1.1
RUN curl --retry 3 http://mirrors.koehn.com/apache//jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz | gunzip| tar x -C /opt
RUN curl --retry 3 --silent https://jmeter-plugins.org/files/packages/jpgc-perfmon-2.0.zip > /opt/plug.zip && \
unzip /opt/plug.zip -d /opt/ && \
cp -R /opt/lib/* /opt/apache-jmeter-$JMETER_VERSION/lib/


ENV PATH="${PATH}:/opt/apache-jmeter-$JMETER_VERSION/bin"

RUN mkdir -p /opt/loadTest
COPY . /opt/loadTest

WORKDIR /opt/loadTest

CMD ./start-load-tests.sh
