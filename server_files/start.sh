cd /app/minecraft/
java -Xmx$MEMORY_MAX -Xtune:virtualized -Xshareclasses:name=minecraft,cacheDir=/app/javasharedresources,nonfatal -jar forge-$FORGE_VERSION-universal.jar
