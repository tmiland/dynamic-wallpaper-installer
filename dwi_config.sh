#!/usr/bin/env bash

cfg_file=$HOME/.dwi/.dwi_config
# Read hidden configuration file with entries separated by " " into array
IFS=' ' read -ra CfgArr < $cfg_file

# Zenity form with current values in entry label
# because initializing multiple entry data fields not supported
output=$(
  zenity --forms --title="Dynamic Wallpaper Configuration" \
    --text="Enter new settings or leave entries blank to keep (existing) settings" \
    --add-entry="Light wallpaper image : (${CfgArr[0]})" \
    --add-entry="Dark wallpaper image : (${CfgArr[1]})" \
    --add-entry="Wallpaper name : (${CfgArr[2]})" \
    --add-entry="Wallpaper image rendering : (${CfgArr[3]})"
)

IFS='|' read -ra ZenArr <<<"$output" # Split zenity entries separated by "|" into array elements

# Update non-blank zenity array entries into configuration array
for i in "${!ZenArr[@]}"; do
  if [[ ${ZenArr[i]} != "" ]]; then CfgArr[i]=${ZenArr[i]} ; fi
done

# write hidden configuration file using array (fields automatically separated by " ")
if [[ ! -f cfg_file ]]; then
  touch $cfg_file
fi
echo "${CfgArr[@]}" > $cfg_file