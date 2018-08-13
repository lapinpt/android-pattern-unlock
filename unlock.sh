#!/system/bin/sh
#
# Android pattern unlock
# Author: Matt Wilson
# Modified : Lapin
# Last Modified : 13 Ago 2018
# Note : Modded for Xiaomi Redmi Note 5 PRO MIUI 10
# Licence: Free to use and share. If this helps you please buy me a beer :)
#
# MAGISK init.d
# nano '/sbin/.core/img/.core/service.d/initprops' 
# sleep 20
# /data/local/unlock.sh > /data/local/init.log

# =======================================================================================================================

# Variables
#
# The pattern should be set based on the following layout:
# 1 2 3
# 4 5 6
# 7 8 9

PATTERN="3 1 7 9" # The unlock pattern to draw, space seperated

COL_1=245                   # X coordinate of column 1 (in pixels)
COL_2=540                   # X coordinate of column 2 (in pixels)
COL_3=830                   # X coordinate of column 3 (in pixels)

ROW_1=1250                   # Y coordinate of row 1 (in pixels)
ROW_2=1550                   # Y coordinate of row 2 (in pixels)
ROW_3=1830                   # Y coordinate of row 3 (in pixels)

MULTIPLIER=1                # Multiplication factor for coordinates. For Nexus 4, set this to 2. For low res phones such as
                            # Samsung Galaxy S2, set this to 1. Experiment with this value if you can't see anything happening.

WAKE_SCREEN_ENABLED=true    # If true, the script will start by sending the power button press event

SWIPE_UP_ENABLED=true       # If true, the script will swipe upwards before drawing the pattern (e.g. for lollipop lockscreen)
SWIPE_UP_X=500              # X coordinate for initial upward swipe. Only used if SWIPE_UP_ENABLED is true
SWIPE_UP_Y_FROM=1900        # Start Y coordinate for initial upward swipe. Only used if SWIPE_UP_ENABLED is true
SWIPE_UP_Y_TO=500           # End Y coordinate for initial upward swipe. Only used if SWIPE_UP_ENABLED is true

# =======================================================================================================================

# Define X&Y coordinates for each of the 9 positions.

X[1]=$(( ${COL_1} * ${MULTIPLIER} ))
X[2]=$(( ${COL_2} * ${MULTIPLIER} ))
X[3]=$(( ${COL_3} * ${MULTIPLIER} ))
X[4]=$(( ${COL_1} * ${MULTIPLIER} ))
X[5]=$(( ${COL_2} * ${MULTIPLIER} ))
X[6]=$(( ${COL_3} * ${MULTIPLIER} ))
X[7]=$(( ${COL_1} * ${MULTIPLIER} ))
X[8]=$(( ${COL_2} * ${MULTIPLIER} ))
X[9]=$(( ${COL_3} * ${MULTIPLIER} ))

Y[1]=$(( ${ROW_1} * ${MULTIPLIER} ))
Y[2]=$(( ${ROW_1} * ${MULTIPLIER} ))
Y[3]=$(( ${ROW_1} * ${MULTIPLIER} ))
Y[4]=$(( ${ROW_2} * ${MULTIPLIER} ))
Y[5]=$(( ${ROW_2} * ${MULTIPLIER} ))
Y[6]=$(( ${ROW_2} * ${MULTIPLIER} ))
Y[7]=$(( ${ROW_3} * ${MULTIPLIER} ))
Y[8]=$(( ${ROW_3} * ${MULTIPLIER} ))
Y[9]=$(( ${ROW_3} * ${MULTIPLIER} ))

# Function definitions

LockScreen() {
  if [ "$(dumpsys power | grep 'Display Power' |  grep -oE '(ON|OFF)')" == "ON" ] ; then
      echo "Screen is already on."
      echo "Turning screen off."
      input keyevent 26         # KEYCODE_POWER
      sleep 1
  fi
}

WakeScreen() {
	if [ "$WAKE_SCREEN_ENABLED" = true ]; then
		input keyevent 26           # KEYCODE_POWER
		sleep 1
	fi
}

SwipeUp() {
	if [ "$SWIPE_UP_ENABLED" = true ]; then
		input swipe ${SWIPE_UP_X} ${SWIPE_UP_Y_FROM} ${SWIPE_UP_X} ${SWIPE_UP_Y_TO} 400
		sleep 1
	fi
}

StartTouch() {
	sendevent /dev/input/event2 3 57 14
}

SendCoordinates () {
	sendevent /dev/input/event2 3 53 $1
	sendevent /dev/input/event2 3 54 $2
	sendevent /dev/input/event2 1 330 1
	sendevent /dev/input/event2 0 0 0
}

FinishTouch() {
	sendevent /dev/input/event2 3 57 4294967295
	sendevent /dev/input/event2 0 0 0
}

SwipePattern() {
	for NUM in $PATTERN
	do
	   echo "Sending $NUM: ${X[$NUM]}, ${Y[$NUM]}"
	   SendCoordinates ${X[$NUM]} ${Y[$NUM]}
	done
}

# Actions

LockScreen
WakeScreen
SwipeUp
StartTouch
SwipePattern
FinishTouch
