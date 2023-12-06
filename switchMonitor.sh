#########################################################################
# File Name: switchMonitor.sh
# Author: BillCong
# mail: cjcbill@gmail.com
# Created Time: 2023年12月05日 星期二 11时40分06秒
#########################################################################

# This shell is used to switch Display for two monitor

#!/bin/bash

primary_resolution_info=$(xrandr --query | grep -E "connected primary [0-9]+x[0-9]+\+[0-9]+\+[0-9]+" -o)

read -r primary_width primary_height primary_x_coord primary_y_coord <<< "$(echo "$primary_resolution_info" | awk -F '[ x+]' '/connected primary/ {print $3, $4, $5, $6}')"

echo "Width: $primary_width, Height: $primary_height, X Coordinate: $primary_x_coord, Y Coordinate: $primary_y_coord"
next_resolution_info=$(xrandr --query | grep -v "primary" | grep -E "connected [0-9]+x[0-9]+\+[0-9]+\+[0-9]+" -o)
read -r next_width next_height next_x_coord next_y_coord <<< "$(echo "$next_resolution_info" | awk -F '[ x+]' '/connected/ {print $2, $3, $4, $5}')"
echo "Width: $next_width, Height: $next_height, X Coordinate: $next_x_coord, Y Coordinate: $next_y_coord"

getwindowat() {
    # move mouse to coordinates provided, get window id beneath it, move mouse back
    eval `xdotool mousemove $1 $2 getmouselocation --shell mousemove restore`
    echo $WINDOW
}

# get active app
active=`xdotool getactivewindow`
# get coordinates of an active app
eval `xdotool getwindowgeometry --shell $active`

echo "primary x_coord: $primary_x_coord y_coord: $primary_y_coord"
echo "next x_coord: $next_x_coord y_coord: $next_y_coord"
echo "Current window X coord: $X Y coord: $Y"

if [[ $next_x_coord == 0 && $primary_x_coord == $next_width ]]; then
    # primary is at the right side
    echo "primary is at the right side"
    if [[ $X -ge $next_width ]]; then
        echo "current window is in primary monitor, should go to next monitor"
        searchx=$[ $next_x_coord + ($next_width / 2) ]
        searchy=$[ $next_y_coord + ($next_height / 2) ]
    else
        echo "current window is in next monitor, should go to primary monitor"
        searchx=$[ $primary_x_coord + ($primary_width / 2) ]
        searchy=$[ $primary_y_coord + ($primary_height / 2) ]
    fi

elif [[ $primary_x_coord == 0 && $next_x_coord == $primary_width ]]; then
    # primary is at the left side
    echo "primary is at the left side"
    if [[ "$X" -le "$primary_width" ]]; then
        echo "current window is in primary monitor, should go to next monitor"
        searchx=$[ $next_x_coord + ($next_width / 2) ]
        searchy=$[ $next_y_coord + ($next_height / 2) ]
    else
        echo "current window is in next monitor, should go to primary monitor"
        searchx=$[ $primary_x_coord + ($primary_width / 2) ]
        searchy=$[ $primary_y_coord + ($primary_height / 2) ]
    fi
elif [[ $next_y_coord == 0 && $primary_y_coord == $next_height ]]; then
    # primary is at the bottom
    echo "primary is at the bottom, should go to next monitor"
    if [[ $Y -ge $next_height ]]; then
        echo "current window is in primary monitor, should go to next monitor"
        searchx=$[ $next_x_coord + ($next_width / 2) ]
        searchy=$[ $next_y_coord + ($next_height / 2) ]
    else
        echo "current window is in next monitor, should go to primary monitor"
        searchx=$[ $primary_x_coord + ($primary_width / 2) ]
        searchy=$[ $primary_y_coord + ($primary_height / 2) ]
fi
elif [[ $primary_y_coord == 0 && $next_y_coord == $primary_height ]]; then
    # primary is at the top
    echo "primary is at the top"
    if [[ $Y < $primary_height ]]; then
        echo "current window is in primary monitor, should go to next monitor"
        searchx=$[ $next_x_coord + ($next_width / 2) ]
        searchy=$[ $next_y_coord + ($next_height / 2) ]
    else
        echo "current window is in next monitor, should go to primary monitor"
        searchx=$[ $primary_x_coord + ($primary_width / 2) ]
        searchy=$[ $primary_y_coord + ($primary_height / 2) ]
fi
else
    echo "Error: Unknown primary position"
    exit 1
fi

echo "searchx: $searchx searchy: $searchy"

# get window in that position
window=`getwindowat $searchx $searchy`
# activate it
xdotool windowactivate $window
xdotool mousemove $searchx $searchy
