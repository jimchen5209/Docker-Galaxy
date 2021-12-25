ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
ARG FABRIC_INSTALLER=0.10.2
ARG MINECRAFT_VERSION=1.18.1

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
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.2/lazydfu-0.1.2.jar"
## Krypton
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/0.1.6/krypton-0.1.6.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/v1.1.6/FabricProxy-Lite-1.1.6.jar"
## Starlight
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/H8CaAYZC/versions/Starlight%201.0.0%201.18.x/starlight-1.0.0+fabric.d0a3220.jar"
## FerriteCore
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/uXXizFIs/versions/3.1.0/ferritecore-3.1.0-fabric.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/gvQqBUqZ/versions/mc1.18.1-0.7.6/lithium-fabric-mc1.18.1-0.7.6.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/0.45.0+1.18/fabric-api-0.45.0+1.18.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://ci.lucko.me/job/spark/lastSuccessfulBuild/artifact/spark-fabric/build/libs/spark-fabric.jar"
## Hydrogen
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.discordapp.com/attachments/361495932971515904/916695488563130398/hydrogen-fabric-mc1.18-0.3-SNAPSHOT.jar"

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
