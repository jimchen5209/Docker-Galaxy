FROM adoptopenjdk/openjdk8-openj9:slim

ENV MEMORY_MAX 1G
ENV SPONGE_VERSION 1.12.2-2768-7.1.4
# Forge Version {Minecraft Version}-{Forge Version} Example => 1.12.2-14.23.5.2768
ENV FORGE_VERSION 1.12.2-14.23.5.2768

RUN mkdir -p /app/minecraft/mods /app/control

WORKDIR /app/minecraft

RUN apt-get update && apt-get install -y wget && \
    wget https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${SPONGE_VERSION}/spongeforge-${SPONGE_VERSION}.jar -O mods/spongeforge-${SPONGE_VERSION}.jar && \
    wget https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar && \
    wget https://github.com/Tiiffi/mcrcon/releases/download/v0.0.5/mcrcon-0.0.5-linux-x86-64.tar.gz -O /app/control/mcrcon.tar.gz && \
    apt-get purge -y wget && \
    chown -R 1000:1000 /app/minecraft

COPY control_files/* /app/control/
RUN bash /app/control/install.sh

USER 1000:1000

RUN java -jar forge-${FORGE_VERSION}-installer.jar --installServer && rm forge-${FORGE_VERSION}-installer.jar forge-${FORGE_VERSION}-installer.jar.log
COPY --chown=1000:1000 server_files/* /app/minecraft/

EXPOSE 25565
ENTRYPOINT ["bash"]
CMD ["/app/minecraft/start.sh"]
