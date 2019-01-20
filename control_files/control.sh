function sendRequest(){
    ./mcrcon -H 127.0.0.1 -P 23456 $@
}

function ping(){
    sendRequest "sponge version"
}

function stop(){
    sendRequest "stop"
}

case $1 in
    ping)
        ping
        ;;
    stop)
        stop
        ;;
esac
