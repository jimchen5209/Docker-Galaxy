#!/bin/bash

apt-get update
apt-get install --no-install-recommends -y ca-certificates wget

# Download mcrcon
wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/${MCRCON_VERSION}/${MCRCON_TAR_FILE}"
# Download Forge
wget --progress=bar:force "https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"
# Download Sponge
wget --progress=bar:force "https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${SPONGE_VERSION}/spongeforge-${SPONGE_VERSION}.jar"

apt-get purge --auto-remove -y ca-certificates wget
rm -rf /var/lib/apt/lists/*

cat "${MCRCON_TAR_FILE}" | tar xz -C /app/control/ mcrcon
rm "${MCRCON_TAR_FILE}"
mkdir mods
mv "spongeforge-${SPONGE_VERSION}.jar" "mods/"

# Install Forge
java -jar "forge-${FORGE_VERSION}-installer.jar" --installServer

# cleanup
rm "forge-${FORGE_VERSION}-installer.jar" "forge-${FORGE_VERSION}-installer.jar.log"

# chown
chown -R 1000 /app/minecraft