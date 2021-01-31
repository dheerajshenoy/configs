#!/bin/sh
t=$(calcurse -t | grep 1 | sed 's/1.//')
echo " TODO:$t   "
