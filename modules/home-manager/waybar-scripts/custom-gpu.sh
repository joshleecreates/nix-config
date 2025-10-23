#!/bin/bash

raw_clock=$(cat /sys/class/drm/card0/device/pp_dpm_sclk 2>/dev/null | egrep -o '[0-9]{0,4}Mhz \W' | sed "s/Mhz \*//")
clock=$(echo "scale=1;$raw_clock/1000" | bc 2>/dev/null | sed -e 's/^-\./-0./' -e 's/^\./0./')

raw_temp=$(cat /sys/class/drm/card0/device/hwmon/hwmon5/temp1_input 2>/dev/null)
temperature=$(($raw_temp/1000))
busypercent=$(cat /sys/class/hwmon/hwmon5/device/gpu_busy_percent 2>/dev/null)
deviceinfo=$(glxinfo -B 2>/dev/null | grep 'Device:' | sed 's/^.*: //')
driverinfo=$(glxinfo -B 2>/dev/null | grep "OpenGL version")

echo '{"text": "'$clock'GHz |   '$temperature'°C <span color=\"darkgray\">| '$busypercent'%</span>", "class": "custom-gpu", "tooltip": "<b>'$deviceinfo'</b>\n'$driverinfo'"}'
