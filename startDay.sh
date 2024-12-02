#!/bin/zsh

year=$(date "+%Y")
day=$1

dir=$year/$day
mkdir -p $dir
cp skel/* $dir
