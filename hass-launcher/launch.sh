#!/bin/bash

dir="$(dirname "$0")"

. $dir/config

ssh -nN -R $SERVER_PORT:localhost:$LOCAL_PORT -i $SSH_KEY_PATH $USER@$HOST &
tunel_pid=$!

trap onexit INT
function onexit() {
    kill -9 $tunel_pid
}

hass --open-ui
