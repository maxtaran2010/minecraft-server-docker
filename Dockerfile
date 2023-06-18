# Example of custom Java runtime using jlink in a multi-stage container build
FROM  amazoncorretto:17-alpine as jre-build

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules java.base,java.xml,java.management,java.desktop,java.logging,jdk.zipfs,java.sql \
	 --strip-java-debug-attributes \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

# Define your base image
FROM alpine:latest
ENV JAVA_HOME="/opt/java/openjdk"
ENV PATH "${JAVA_HOME}/bin:${PATH}"
ENV JVM_ARGS="-Xmx1G -Xms1G"

COPY --from=jre-build /javaruntime $JAVA_HOME

# Continue with your application deployment
RUN mkdir /opt/app
RUN mkdir /opt/data
WORKDIR /opt/data
COPY server.jar /opt/app

VOLUME ["/opt/data"]

ENTRYPOINT java $JVM_ARGS -jar /opt/app/server.jar --nogui
