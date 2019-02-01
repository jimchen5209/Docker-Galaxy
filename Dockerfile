ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
# Forge Version {Minecraft Version}-{Forge Version} Example => 1.12.2-14.23.5.2768
ARG FORGE_VERSION=1.12.2-14.23.5.2768
ARG SPONGE_VERSION=1.12.2-2768-7.1.4

FROM adoptopenjdk/openjdk8-openj9:slim
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FORGE_VERSION
ARG SPONGE_VERSION
# Env setup
ENV PATH="/app/control:${PATH}"
ENV MEMORY_MAX 1G
ENV FORGE_VERSION ${FORGE_VERSION}
WORKDIR /app/minecraft

COPY app /app

RUN ../installer.sh && rm ../installer.sh

# Run Server
USER 1000
EXPOSE 25565
ENTRYPOINT ["bash"]
CMD ["/app/minecraft/start.sh"]
