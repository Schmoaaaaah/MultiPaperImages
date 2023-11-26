# Example of custom Java runtime using jlink in a multi-stage container build
FROM ibm-semeru-runtimes:open-17-jdk-jammy as java-runtime

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -yq --no-install-recommends binutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules java.base,java.compiler,java.logging,java.management,java.scripting,java.net.http,java.sql,java.desktop,java.security.sasl,java.naming,java.transaction.xa,java.xml,jdk.crypto.ec,jdk.zipfs,jdk.security.auth,jdk.unsupported  \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

# Define your base image
FROM ubuntu:jammy as base
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=java-runtime /javaruntime $JAVA_HOME
ENV PATH "${JAVA_HOME}/bin:${PATH}"

# Setup groups and install dumb init
RUN addgroup --gid 1001 multipaper && \
    adduser --home /multipaper --uid 1001 -gid 1001 multipaper && \
    chown -R 1001:1001 /opt/java && \
    chmod -R 777 /opt/java && \
    chmod +x $JAVA_HOME/bin/java

# Use the multipaper's home directory as our work directory
WORKDIR /multipaper

FROM base as server

# Switch from root to multipaper
USER multipaper

# Source URL
ARG RELEASE_URL

# Download multipaper
ADD --chown=multipaper:multipaper $RELEASE_URL /multipaper/multipaper.jar

# Expose the required ports
EXPOSE 25565/tcp

# Start the process using dumb-init
ENTRYPOINT ["/opt/java/openjdk/bin/java"]
CMD ["-DmultipaperMasterAddress=master:35353", "-jar", "/multipaper/multipaper.jar"]

# Switch to the data directory
WORKDIR /multipaper/data

FROM base as master

# Source URL
ARG RELEASE_URL

# Download velocity
ADD --chown=multipaper:multipaper $RELEASE_URL /multipaper/multipaper-master.jar

# Expose the ports of the master server and proxy
EXPOSE 35353/tcp
EXPOSE 25565/tcp

# Start the process using dumb-init
ENTRYPOINT ["/opt/java/openjdk/bin/java"]
CMD ["-jar", "/multipaper/multipaper-master.jar", "35353", "25565"]
#CMD [ "/bin/ash", "-c", "while true; do echo 'running' && sleep 30; done;" ]
# Switch to the data directory
WORKDIR /multipaper/data

FROM base as velocity

# Source URL
ARG RELEASE_URL

# Download velocity
ADD --chown=multipaper:multipaper $RELEASE_URL /multipaper/velocity.jar

# Expose the ports of velocity
EXPOSE 25575/tcp

# Start the process using dumb-init
ENTRYPOINT ["/opt/java/openjdk/bin/java"]
CMD ["-Xms1G", "-Xmx1G", "-XX:+UseG1GC", "-XX:G1HeapRegionSize=4M", "-XX:+UnlockExperimentalVMOptions", "-XX:+ParallelRefProcEnabled", "-XX:+AlwaysPreTouch", "-XX:MaxInlineLevel=15", "-jar", "/multipaper/velocity.jar"]
#CMD [ "/bin/ash", "-c", "while true; do echo 'running' && sleep 30; done;" ]
# Switch to the data directory
WORKDIR /multipaper/data