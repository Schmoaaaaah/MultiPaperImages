FROM eclipse-temurin:17-alpine as jre-build

RUN apk add --no-cache binutils

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules java.base \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

# Define your base image
FROM alpine:3.18.4
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

# Continue with your application deployment
CMD [ "/bin/ash", "-c", "while true; do echo 'running' && sleep 30; done;" ]