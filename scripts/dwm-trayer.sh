#!/bin/sh

create_space () {

pixels=$(for i in `seq $1`; do echo -n "."; done)
echo $pixels
};

width=$(xprop -name panel | grep 'program specified minimum size' | cut -d ' ' -f 5)
width=$((width/8))
create_space $width
