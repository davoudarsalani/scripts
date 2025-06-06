#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-color.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-color.sh
##    https://davoudarsalani.ir

## 40 for black
## 49 for transparent
## ∅  for no background


function red {
    printf '\e[0;49;31m%s\e[0m\n' "$@"
}

function green {
    printf '\e[0;49;32m%s\e[0m\n' "$@"
}

function yellow {
    printf '\e[0;49;33m%s\e[0m\n' "$@"
}

function blue {
    printf '\e[0;49;34m%s\e[0m\n' "$@"
}

function purple {
    printf '\e[0;49;35m%s\e[0m\n' "$@"
}

function cyan {
    printf '\e[0;49;36m%s\e[0m\n' "$@"
}

function white {
    printf '\e[0;49;37m%s\e[0m\n' "$@"
}

function gray {
    printf '\e[0;49;90m%s\e[0m\n' "$@"
}

function brown {
    printf '\e[38;5;94m%s\e[0m\n' "$@"
}

function orange {
    printf '\e[38;5;202m%s\e[0m\n' "$@"
}

function olive {
    printf '\e[38;5;64m%s\e[0m\n' "$@"
}


## bold
function red_bold {
    printf '\e[1;49;31m%s\e[0m\n' "$@"
}

function green_bold {
    printf '\e[1;49;32m%s\e[0m\n' "$@"
}

function yellow_bold {
    printf '\e[1;49;33m%s\e[0m\n' "$@"
}

function blue_bold {
    printf '\e[1;49;34m%s\e[0m\n' "$@"
}

function purple_bold {
    printf '\e[1;49;35m%s\e[0m\n' "$@"
}

function cyan_bold {
    printf '\e[1;49;36m%s\e[0m\n' "$@"
}

function white_bold {
    printf '\e[1;49;37m%s\e[0m\n' "$@"
}

function gray_bold {
    printf '\e[1;49;90m%s\e[0m\n' "$@"
}


## dim
function red_dim {
    printf '\e[2;49;31m%s\e[0m\n' "$@"
}

function green_dim {
    printf '\e[2;49;32m%s\e[0m\n' "$@"
}

function yellow_dim {
    printf '\e[2;49;33m%s\e[0m\n' "$@"
}

function blue_dim {
    printf '\e[2;49;34m%s\e[0m\n' "$@"
}

function purple_dim {
    printf '\e[2;49;35m%s\e[0m\n' "$@"
}

function cyan_dim {
    printf '\e[2;49;36m%s\e[0m\n' "$@"
}

function white_dim {
    printf '\e[2;49;37m%s\e[0m\n' "$@"
}

function gray_dim {
    printf '\e[2;49;90m%s\e[0m\n' "$@"
}


## italiac
function red_italic {
    printf '\e[3;49;31m%s\e[0m\n' "$@"
}

function green_italic {
    printf '\e[3;49;32m%s\e[0m\n' "$@"
}

function yellow_italic {
    printf '\e[3;49;33m%s\e[0m\n' "$@"
}

function blue_italic {
    printf '\e[3;49;34m%s\e[0m\n' "$@"
}

function purple_italic {
    printf '\e[3;49;35m%s\e[0m\n' "$@"
}

function cyan_italic {
    printf '\e[3;49;36m%s\e[0m\n' "$@"
}

function white_italic {
    printf '\e[3;49;37m%s\e[0m\n' "$@"
}

function gray_italic {
    printf '\e[3;49;90m%s\e[0m\n' "$@"
}


## underline
function red_underline {
    printf '\e[4;49;31m%s\e[0m\n' "$@"
}

function green_underline {
    printf '\e[4;49;32m%s\e[0m\n' "$@"
}

function yellow_underline {
    printf '\e[4;49;33m%s\e[0m\n' "$@"
}

function blue_underline {
    printf '\e[4;49;34m%s\e[0m\n' "$@"
}

function purple_underline {
    printf '\e[4;49;35m%s\e[0m\n' "$@"
}

function cyan_underline {
    printf '\e[4;49;36m%s\e[0m\n' "$@"
}

function white_underline {
    printf '\e[4;49;37m%s\e[0m\n' "$@"
}

function gray_underline {
    printf '\e[4;49;90m%s\e[0m\n' "$@"
}


## blink
function red_blink {
    printf '\e[5;49;31m%s\e[0m\n' "$@"
}

function green_blink {
    printf '\e[5;49;32m%s\e[0m\n' "$@"
}

function yellow_blink {
    printf '\e[5;49;33m%s\e[0m\n' "$@"
}

function blue_blink {
    printf '\e[5;49;34m%s\e[0m\n' "$@"
}

function purple_blink {
    printf '\e[5;49;35m%s\e[0m\n' "$@"
}

function cyan_blink {
    printf '\e[5;49;36m%s\e[0m\n' "$@"
}

function white_blink {
    printf '\e[5;49;37m%s\e[0m\n' "$@"
}

function gray_blink {
    printf '\e[5;49;90m%s\e[0m\n' "$@"
}


## bg
function red_bg {
    printf '\e[7;49;31m%s\e[0m\n' "$@"
}

function green_bg {
    printf '\e[7;49;32m%s\e[0m\n' "$@"
}

function yellow_bg {
    printf '\e[7;49;33m%s\e[0m\n' "$@"
}

function blue_bg {
    printf '\e[7;49;34m%s\e[0m\n' "$@"
}

function purple_bg {
    printf '\e[7;49;35m%s\e[0m\n' "$@"
}

function cyan_bg {
    printf '\e[7;49;36m%s\e[0m\n' "$@"
}

function white_bg {
    printf '\e[7;49;37m%s\e[0m\n' "$@"
}

function gray_bg {
    printf '\e[7;49;90m%s\e[0m\n' "$@"
}

function brown_bg {
    printf '\e[48;5;94m%s\e[0m\n' "$@"
}

function orange_bg {
    printf '\e[48;5;202m%s\e[0m\n' "$@"
}

function olive_bg {
    printf '\e[48;5;64m%s\e[0m\n' "$@"
}


## strikethrough
function red_strikethrough {
    printf '\e[9;49;31m%s\e[0m\n' "$@"
}

function green_strikethrough {
    printf '\e[9;49;32m%s\e[0m\n' "$@"
}

function yellow_strikethrough {
    printf '\e[9;49;33m%s\e[0m\n' "$@"
}

function blue_strikethrough {
    printf '\e[9;49;34m%s\e[0m\n' "$@"
}

function purple_strikethrough {
    printf '\e[9;49;35m%s\e[0m\n' "$@"
}

function cyan_strikethrough {
    printf '\e[9;49;36m%s\e[0m\n' "$@"
}

function white_strikethrough {
    printf '\e[9;49;37m%s\e[0m\n' "$@"
}

function gray_strikethrough {
    printf '\e[9;49;90m%s\e[0m\n' "$@"
}
