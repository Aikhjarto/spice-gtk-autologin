#!/bin/bash
# login script that opens a spicy client with USB redirection and power saving
# features.
#
# USB redirection has high CPU load even if idle. Thus, this script checks for 
# inactivity of the X-server and quits spice. Then it polls in SLEEP_DURATION
# invervall for activity and starts the spice client again or quits if spice 
# failed.
# 
# Note: usb-redirection might require a password. Use policykit to allow
# action org.spice-space.lowlevelusbaccess for corresponding users.


# debug: start xterm to see if anything is working
#xterm &
#sleep 3

if [ -n "${SPICY_DEBUG}" ]; then
	set -x
fi

SPICY_SLEEP_DURATION=${SPICY_SLEEP_DURATION:-30}
SPICY_IDLE_COUNTER_MS=${SPICY_IDLE_COUNTER_MS:-100000}
SPICY_ERR_FILE=${SPICY_ERR_FILE:-/tmp/spicy.log}
SPICY_PORT=${SPICY_PORT:-5900}
SPICY_HOST=${SPICY_HOST:-localhost}
SPICY_EXTRA_ARG=${SPICY_EXTRA_ARG:-"--spice-usbredir-redirect-on-connect='-1,0x413c,0x2107,-1,1'"}
# Requires: xset
# Requires: spice-gtk
# Requires: libspice-client-glib-helper
# Requires: icewm
# Requires: xprintidle
# Requires: sysvinit-tools
# Requires: alsa
# We need a minimal window manager to make spice window fullscreen.
icewm-lite &

/usr/bin/pulseaudio --start --log-target=syslog
# debug: play a short sound
if [ -n "${SPICY_DEBUG}" ]; then
	speaker-test -l 1 &
fi

# Power modes of display are somehow off by default. Enable here.
xset +dpms

# start spicy
spicy -f -h ${SPICY_HOST} -p ${SPICY_PORT} ${SPICY_EXTRA_ARG} &> ${SPICY_ERR_FILE} &


# Wait with first check until .xsession-errors is overwritten and spicy is started
sleep ${SPICY_SLEEP_DURATION}


echo spicy log is in ${ERR_FILE}
# channel error appear in log if VM is not ready (still starting or temporarily off)
while ! grep "main channel\: failed to connect\|GSpice-Message\: main channel\: closed" ${SPICY_ERR_FILE}
	do 
	# xprintidle returns time in ms since last user input
	# Note, only mouse counts since keyboard is bound to vm
	if [ $(xprintidle) -gt ${SPICY_IDLE_COUNTER_MS} ]; then

		# kill spicy
		killall -q spicy

		# Deactivate display to allow monitor to sleep (and save power).
		xset dpms force off
	else 
		# check if spicy is running and restart if not
		# if [ -z $(readlink /proc/*/exe | grep /usr/bin/spicy) ]; then
		if [ -z $(pidof /usr/bin/spicy)  ]; then

			# if not, start it
			spicy -f -h ${SPICY_HOST} -p ${SPICY_PORT} ${SPICY_EXTRA_ARG} &> ${SPICY_ERR_FILE} &
			# activating display is done anyways by something (maybe xdm)
		fi
	fi
	
	# wait until next poll
	sleep ${SPICY_SLEEP_DURATION}
done


# debug: show something prior end
#xterm &
#sleep 1

