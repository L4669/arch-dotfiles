#!/bin/bash

# the script shows the list of active windows in wayland (hyprland)
# uses wofi dmenu to display the list
# selected window is brought to focus

# source: https://github.com/hyprwm/Hyprland/discussions/830
# hyprctl output in json: https://github.com/hyprwm/Hyprland/issues/3428
# regex check: https://regex101.com/

# list all active windows in json format
CLIENTS=$(hyprctl clients -j)
# variable to store total number of active windows
LEN=0 

# extract addresses of the active windows and save in array
ADDR=$(grep -oP "(?<=\"address\": \")[^\"]*" <<< $CLIENTS)
addr_arr=()
for i in $ADDR; do addr_arr+=($i) LEN=`expr $LEN + 1`; done

# extract name of the active windows and save in array
CLASS=$(grep -oP "(?<=\"class\": \")[^\"]*" <<< $CLIENTS)
class_arr=()
for i in $CLASS; do class_arr+=($i); done

# extract workspace of the active windows and save in array
WNAME=$(grep -oP "(?<=\"name\": \")[^\"]*" <<< $CLIENTS)
wname_arr=()
for i in $WNAME; do wname_arr+=($i); done

# prepare the list to be input to wofi dmenu
WOFI=""
for i in $(seq $LEN)
do
    WOFI_INPUT="ws:${wname_arr[i-1]} | addr:${addr_arr[i-1]} | ${class_arr[i-1]}"
    WOFI+=$(printf '%s' "$WOFI_INPUT")$'\n'
done

# call for wofi dmenu. displays the list prepared above
WINDOW=$(wofi --show dmenu --insensitive <<< "$WOFI")

# wofi dmenu output processing to get the window selected
# using address to uniquely identify the window to be focused
FOCUS=$(grep -oP "(?<=addr:)[^\"\|\ ]*" <<< $WINDOW)

if [ "$WINDOW" = "" ]; then
    exit
fi

# making the window focused
hyprctl dispatch focuswindow address:$FOCUS


#CLIENTS=$(hyprctl clients -j | grep -P "\"address\": \"[A-Za-z0-9]+\"")
#WINDOW=$(tr ' ' <<< $WOFI_INPUT | wofi --show dmenu)
# hyprctl dispatch focuswindow $WINDOW (focus using window name)
