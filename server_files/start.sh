cd /app/minecraft/
find . -iname "level*.dat" -type f -empty -delete
java -Xmx$MEMORY_MAX -Xtune:virtualized -Xshareclasses:name=minecraft,cacheDir=/app/javasharedresources,nonfatal -jar forge-$FORGE_VERSION-universal.jar
