FROM openjdk:8-jre-slim

ENV MEMORY_MAX 1G
ENV SPONGE_VERSION 1.12.2-2768-7.1.4
# Forge Version {Minecraft Version}-{Forge Version} Example => 1.12.2-14.23.5.2768
ENV FORGE_VERSION 1.12.2-14.23.5.2768

RUN mkdir -p /app/minecraft/mods

WORKDIR /app/minecraft

ADD https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${SPONGE_VERSION}/spongeforge-${SPONGE_VERSION}.jar /app/minecraft/mods/spongeforge-${SPONGE_VERSION}.jar
ADD https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar /app/minecraft/forgeInstaller.jar

RUN java -jar forgeInstaller.jar --installServer

COPY server_files/* /app/minecraft/

EXPOSE 25565
ENTRYPOINT ["bash"]
CMD ["/app/minecraft/start.sh","${MEMORY_MAX}","${FORGE_VERSION}"]
