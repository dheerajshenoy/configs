#! /bin/sh
current_gap=$(bspc config window_gap)
increase_rate=1
decrease_rate=1
def=5
let "inc= $current_gap + increase_rate"
let "dec=$current_gap - decrease_rate"

if [[ "$1" == "inc" ]]
then
    bspc config window_gap $inc
elif [[ "$1" == "dec" && "$current_gap" > "0" ]]
then
    bspc config window_gap $dec
elif [[ "$1" == "eql" ]]
then
    bspc config window_gap $def
fi

