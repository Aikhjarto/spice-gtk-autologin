#!/bin/bash

# stop plymouth
/usr/bin/plymouth quit --retain-splash

# access to XAUTHORTY file
chown spicy:users $XAUTHORITY

# set setuid bit for acl-helper to allow keyboard forwarding
chmod +s /usr/bin/spice-client-glib-usb-acl-helper

# reset pulseaudio (prvent quirx with sudo)
export XDG_RUNTIME_DIR=""

install -o spicy -g spicy -d /var/run/spicy
sudo -E -u spicy /usr/bin/spicy_xinit.sh

# for some reason setting a group with sudo results in
#  root : command not allowed ; TTY=unknown ; PWD=/ ; USER=thomas ; GROUP=audio ; COMMAND=/usr/local/bin/test_logout.sh
#sudo  -u thomas -g audio /usr/local/bin/test_logout.sh

