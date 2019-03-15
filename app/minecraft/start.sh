cd /app/minecraft/
find . -iname "level*.dat" -type f -size 0 -delete
java -Xmx$MEMORY_MAX -Xtune:virtualized -Xshareclasses:name=minecraft,cacheDir=/app/javasharedresources,nonfatal -jar forge-$FORGE_VERSION-universal.jar
