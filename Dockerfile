ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
# Forge Version {Minecraft Version}-{Forge Version} Example => 1.12.2-14.23.5.2768
ARG FORGE_VERSION=1.12.2-14.23.5.2768
ARG SPONGE_VERSION=1.12.2-2768-7.1.4

FROM adoptopenjdk/openjdk8-openj9:slim as downloader
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FORGE_VERSION
ARG SPONGE_VERSION
WORKDIR /app/minecraft
COPY app /app

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates wget && mkdir mods
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/${MCRCON_VERSION}/${MCRCON_TAR_FILE}" -O - | tar xz -C /app/control/ mcrcon
# Download Forge
RUN wget --progress=bar:force "https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar" && \
    java -jar "forge-${FORGE_VERSION}-installer.jar" --installServer && \
    rm "forge-${FORGE_VERSION}-installer.jar" "forge-${FORGE_VERSION}-installer.jar.log"
# Download Sponge
RUN wget --progress=bar:force "https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${SPONGE_VERSION}/spongeforge-${SPONGE_VERSION}.jar" && \
    mv "spongeforge-${SPONGE_VERSION}.jar" "mods/"
RUN chown -R 1000 /app/minecraft


FROM adoptopenjdk/openjdk8-openj9:slim
ARG FORGE_VERSION
# Env setup
ENV PATH="/app/control:${PATH}"
ENV MEMORY_MAX 1G
ENV FORGE_VERSION ${FORGE_VERSION}
WORKDIR /app/minecraft

COPY --from=downloader /app/ /app/

# Run Server
USER 1000
EXPOSE 25565
ENTRYPOINT ["bash"]
CMD ["/app/minecraft/start.sh"]
