MAX_MEMORY=$1
FORGE_VERSION=$2
java -Xmx$MAX_MEMORY -XX:+UseG1GC -jar forge-$FORGE_VERSION-universal.jar