ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
ARG FABRIC_INSTALLER=0.11.0
ARG MINECRAFT_VERSION=1.19

FROM ibm-semeru-runtimes:open-17-jre-focal as builder
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FABRIC_INSTALLER
ARG MINECRAFT_VERSION
WORKDIR /app/minecraft
COPY app /app

RUN apt-get update && apt-get install -y wget ca-certificates
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/${MCRCON_VERSION}/${MCRCON_TAR_FILE}" -O - | tar xz -C /app/control/ mcrcon

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER}/fabric-installer-${FABRIC_INSTALLER}.jar" && \
    java -jar fabric-installer-${FABRIC_INSTALLER}.jar server -mcversion ${MINECRAFT_VERSION} -downloadMinecraft && \
    java -jar fabric-server-launch.jar --nogui --initSettings && \
    rm fabric-installer-${FABRIC_INSTALLER}.jar

# Download mods
## LazyDFU
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar"
## Krypton
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/0.2.0/krypton-0.2.0.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/v2.1.0/FabricProxy-Lite-2.1.0.jar"
## Starlight
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.1+1.19/starlight-1.1.1%2Bfabric.ae22326.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/gvQqBUqZ/versions/mc1.19-0.8.0/lithium-fabric-mc1.19-0.8.0.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/0.56.3+1.19/fabric-api-0.56.3%2B1.19.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://ci.lucko.me/job/spark/318/artifact/spark-fabric/build/libs/spark-1.9.17-fabric.jar"

FROM ibm-semeru-runtimes:open-17-jre-focal
# Env setup
ENV PATH="/app/control:${PATH}"

RUN apt-get update && apt-get install -y ca-certificates

# Copy server files
COPY --from=builder /app/control /app/control
COPY --from=builder --chown=1000 /app/minecraft /app/minecraft

# Copy mods
COPY --chown=1000 mods/* /app/minecraft/mods/

# Run Server
WORKDIR /app/minecraft
USER 1000
EXPOSE 25565
CMD ["java", "-XX:MaxRAMPercentage=80", "-Xaggressive", "-Xalwaysclassgc","-XX:IdleTuningMinIdleWaitTime=1", "-Xjit:waitTimeToEnterDeepIdleMode=1000", "-Xgc:concurrentScavenge", "-Xdump:none", "-Xdump:console", "-jar", "fabric-server-launch.jar"]
