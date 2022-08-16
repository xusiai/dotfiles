#!/usr/bin/env bash


dir="$HOME/.config/rofi/launcher"
theme='SAGA'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
