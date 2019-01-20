FROM adoptopenjdk/openjdk8-openj9:slim

# Env setup
ENV MEMORY_MAX 1G
ENV SPONGE_VERSION 1.12.2-2768-7.1.4
# Forge Version {Minecraft Version}-{Forge Version} Example => 1.12.2-14.23.5.2768
ENV FORGE_VERSION 1.12.2-14.23.5.2768

WORKDIR /app/minecraft

# Copy files
COPY control_files/* /app/control/
COPY --chown=1000 server_files /app/minecraft

# Download mcrcon
RUN apt-get update && apt-get install -y wget && \
    wget -q -O - "https://github.com/OKTW-Network/mcrcon/releases/download/v0.0.6/mcrcon-0.0.6-linux-x86-64.tar.gz" | tar xz -C /app/control/ mcrcon && \
    apt-get purge -y wget && \
    rm -rf /var/lib/apt/lists/*

# Install Forge install
RUN apt-get update && apt-get install -y wget && \
    wget https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar && \
    java -jar forge-${FORGE_VERSION}-installer.jar --installServer && \
    rm forge-${FORGE_VERSION}-installer.jar forge-${FORGE_VERSION}-installer.jar.log && \
    chown -R 1000 /app/* && \
    apt-get purge -y wget && \
    rm -rf /var/lib/apt/lists/*

# Download Sponge
ADD --chown=1000 https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${SPONGE_VERSION}/spongeforge-${SPONGE_VERSION}.jar mods/spongeforge-${SPONGE_VERSION}.jar

# Run Server
USER 1000
EXPOSE 25565
ENTRYPOINT ["bash"]
CMD ["/app/minecraft/start.sh"]
