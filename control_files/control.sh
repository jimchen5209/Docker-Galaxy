runResult=""
runExitCode=0

function sendRequest(){
    local command="$@"
    runResult=`./mcrcon -H 127.0.0.1 -P 23456 "$command"`
    runExitCode=$?
}

function ping(){
    sendRequest "sponge version"
    if [[ runExitCode == 0 ]] ; then
        echo 0
        runExitCode=0
    else
        echo 1
        runExitCode=1
    fi
}

function stop(){
    sendRequest "stop"
    if [[ runExitCode == 0 ]] ; then
        waitingStop=1
        until [ waitingStop == 0 ]
        do
            if $(ping) == 0 ; then
                waitingStop=0
            fi
            sleep 1
        done
        runExitCode=0
    else
        runExitCode=1
    fi
}