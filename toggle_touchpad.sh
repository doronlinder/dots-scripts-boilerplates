#!/bin/bash

TEMPFILE=/tmp/.touchpad_enabled
TOUCHPAD_ID=$(xinput | grep TouchPad | cut -f2 -d= | cut -f1)
TOUCHPAD_ENABLED=$(cat $TEMPFILE 2>/dev/null)

if [[ ${TOUCHPAD_ENABLED:-1} -eq 1 ]]; then
    TOUCHPAD_ENABLED=0;
else
    TOUCHPAD_ENABLED=1;
fi

xinput set-prop $TOUCHPAD_ID "Device Enabled" $TOUCHPAD_ENABLED

echo $TOUCHPAD_ENABLED > $TEMPFILE
