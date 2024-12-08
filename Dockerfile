##
## Build
##
FROM maven:3.8.4-openjdk-11-slim AS build

WORKDIR /helloworld/

ADD pom.xml /helloworld
RUN mvn dependency:go-offline

ADD src/ /helloworld/src
RUN mvn clean package

##
## Run
## Pin our tomcat version to something that has not been updated to remove the vulnerability
FROM tomcat:9.0.59-jre11-openjdk-slim

#  Deploy to tomcat
COPY --from=build /helloworld/target/helloworld.war /usr/local/tomcat/webapps/

#  Ability to debug tomcat
ENV JPDA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
EXPOSE 8080
EXPOSE 8000
ENTRYPOINT ["catalina.sh", "jpda", "run"]

# Twistlock Container Defender - app embedded
ADD twistlock_defender_app_embedded.tar.gz /tmp
ENV DEFENDER_TYPE="appEmbedded"
ENV DEFENDER_APP_ID="s4s"
ENV FILESYSTEM_MONITORING="true"
ENV WS_ADDRESS="wss://asia-southeast1.cloud.twistlock.com:443"
ENV DATA_FOLDER="/tmp"
ENV INSTALL_BUNDLE="eyJzZWNyZXRzIjp7InNlcnZpY2UtcGFyYW1ldGVyIjoiNFY3U1F3Yjh3eURreS9LKzVJa0E1NUZBVUQvK3dicHYzZWpkQXFNRmpKTGNVeTZkMWwrVHIvUUZ2cFJzT2p4b1FaK2J4TlQwb2JRK0FCbnVLTEEzS2c9PSJ9LCJnbG9iYWxQcm94eU9wdCI6eyJodHRwUHJveHkiOiIiLCJub1Byb3h5IjoiIiwiY2EiOiIiLCJ1c2VyIjoiIiwicGFzc3dvcmQiOnsiZW5jcnlwdGVkIjoiIn19LCJjdXN0b21lcklEIjoiYXdzLXNpbmdhcG9yZS05NjExNDk3NTgiLCJhcGlLZXkiOiJIRE1Ka3Q4cXlLZkFkN0l2ZmtLNDUwZUpuVDQrQkFXd213WTlVdWNWMk15STVub2Q1UVZpcHpOQzZWdkM2WHFPT1E3S1BXOGNweHlPU2VKakN5dmF0dz09IiwibWljcm9zZWdDb21wYXRpYmxlIjpmYWxzZSwiaW1hZ2VTY2FuSUQiOiIwN2FlZDJhYS1kNDgwLTVjMzAtNjBkNC01NzdhMGMwMmZmYjIifQ=="
ENV FIPS_ENABLED="false"
ENTRYPOINT ["/tmp/defender", "app-embedded", "catalina.sh", "jpda", "run"]
