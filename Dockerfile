FROM java:7-jdk-alpine

ENV JAVA_HOME=/usr/lib/jvm/java-1.7-openjdk TSDB_VERSION=2.2.0 TSDB_HOME=/opentsdb

RUN apk --update add rsyslog make bash \
	&& apk --update add --virtual builddeps build-base autoconf automake git python

RUN wget -O v${TSDB_VERSION}.zip https://github.com/OpenTSDB/opentsdb/archive/v${TSDB_VERSION}.zip \
	&& unzip v${TSDB_VERSION}.zip \
	&& mv opentsdb-${TSDB_VERSION} ${TSDB_HOME} \
	&& rm -f v${TSDB_VERSION}.zip

WORKDIR $TSDB_HOME

RUN ./build.sh

RUN apk del builddeps \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p cache /etc/opentsdb

VOLUME ["$TSDB_HOME/cache", "/etc/opentsdb"]

EXPOSE 3636

CMD ["./build/tsdb", "tsd", "--port=3636", "--staticroot=./build/staticroot", "--cachedir=./cache"]