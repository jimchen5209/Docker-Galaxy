#!/usr/bin/env bash
function sendRequest(){
    /app/control/mcrcon -s -H localhost -p password -P 23456 $@
}

function ping(){
    sendRequest "sponge version"
}

function stop(){
    sendRequest "stop"
}

function command(){
    sendRequest $@
}

case $1 in
    ping)
        ping
        ;;
    stop)
        stop
        ;;
    command)
        command "${@:2}"
        ;;
esac
