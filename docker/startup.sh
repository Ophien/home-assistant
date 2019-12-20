#!/bin/sh
. /home/ssh_tunel/config
ssh -nN -R $SSH_TUNEL_MIDDLEWARE_PORT:localhost:8123 -o StrictHostKeyChecking=no -i /home/ssh_tunel/private-key-hass $SSH_TUNEL_MIDDLEWARE_USER@$SSH_TUNEL_MIDDLEWARE &
hass --open-ui