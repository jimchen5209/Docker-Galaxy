ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
ARG FABRIC_INSTALLER=0.10.0
ARG MINECRAFT_VERSION=1.18

FROM eclipse-temurin:17 as jre-build

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
    --add-modules ALL-MODULE-PATH \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime

FROM debian:bullseye-slim as builder
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FABRIC_INSTALLER
ARG MINECRAFT_VERSION
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
WORKDIR /app/minecraft
COPY --from=jre-build /javaruntime $JAVA_HOME
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
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/0.1.5/krypton-0.1.5.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/v1.1.6/FabricProxy-Lite-1.1.6.jar"
## Starlight
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.discordapp.com/attachments/802420410377437195/911798569764270081/starlight-1.0.0fabric.9f82e79.jar"
## FerriteCore
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/uXXizFIs/versions/3.1.0/ferritecore-3.1.0-fabric.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.discordapp.com/attachments/361495932971515904/916694321296715826/lithium-fabric-mc1.18-0.7.6-SNAPSHOT.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/0.44.0+1.18/fabric-api-0.44.0+1.18.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://ci.lucko.me/job/spark/lastSuccessfulBuild/artifact/spark-fabric/build/libs/spark-fabric.jar"
## Hydrogen
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.discordapp.com/attachments/361495932971515904/916695488563130398/hydrogen-fabric-mc1.18-0.3-SNAPSHOT.jar"

FROM debian:bullseye-slim
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

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
CMD ["java", "-XX:MaxRAMPercentage=80", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseShenandoahGC", "-XX:ShenandoahGuaranteedGCInterval=30000", "-XX:ShenandoahUncommitDelay=5000", "-jar", "fabric-server-launch.jar"]
