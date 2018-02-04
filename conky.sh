#! /bin/sh

if [ "$1" = "start" ]; then
    conky -qdbc `realpath ${CONKYRC:-default "~/.conkyrc"}`
elif [ "$1" = "stop" ]; then
    killall conky
else
    echo "$0 <start|stop>"
fi

