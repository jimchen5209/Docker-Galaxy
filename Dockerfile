FROM openjdk:8-jre-slim

ENV MEMORY_MAX 1G
ENV SPONGE_VERSION 1.12.2-2768-7.1.4
# Forge Version {Minecraft Version}-{Forge Version} Example => 1.12.2-14.23.5.2768
ENV FORGE_VERSION 1.12.2-14.23.5.2768

RUN mkdir -p /app/minecraft/mods /app/control

WORKDIR /app/minecraft

ADD https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${SPONGE_VERSION}/spongeforge-${SPONGE_VERSION}.jar /app/minecraft/mods/spongeForge.jar
ADD https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar /app/minecraft/forgeInstaller.jar
ADD https://github.com/Tiiffi/mcrcon/releases/download/v0.0.5/mcrcon-0.0.5-linux-x86-64.tar.gz /app/control/mcrcon.tar.gz

COPY server_files/* /app/minecraft/
COPY control_files/* /app/control/

RUN java -jar forgeInstaller.jar --installServer
RUN bash /app/control/install.sh

EXPOSE 25565
ENTRYPOINT ["bash"]
CMD ["/app/minecraft/start.sh"]
