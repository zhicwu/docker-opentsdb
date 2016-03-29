# docker-opentsdb
OpenTSDB docker image for development and testing purposes. https://hub.docker.com/r/zhicwu/opentsdb/

## What's inside
```
java:7-jdk-alpine
 |
 |--- zhicwu/opentsdb:latest
```

* Open JDK 7 latest release
* [OpenTSDB](http://opentsdb.net/) latest stable release

## How to use
- Pull the image
```
# docker pull zhicwu/opentsdb
```
- Setup scripts
```
# git clone https://github.com/zhicwu/docker-opentsdb.git
# chmod +x *.sh
```
- Edit opentsdb-env.sh as required
- Start OpenTSDB
```
# ./start-opentsdb.sh
# docker logs -f my-opentsdb
