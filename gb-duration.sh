#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-duration.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-duration.sh
##    https://davoudarsalani.ir

function get_duration {
    local file_ duration

    file_="$1"
    if [ "$2" == 'seconds' ]; then
        duration="$(mediainfo -f --output=JSON "$file_" | jq -rM .'media.track[1].Duration')"   ## 423.120
    else
        duration="$(mediainfo -f --output=JSON "$file_" | jq -rM .'media.track[1].Duration_String3')"   ## 01:46:17.354
    fi

    ## remove .354
    duration="$(printf '%s\n' "$duration" | sed 's#\.[0-9]\+##g')"  ## 01:46:17

    printf '%s\n' "$duration"
}

function shorten_duration {
    local dur four_col_pattern reg_pattern_1 reg_pattern_2 reg_pattern_3

    dur="$1"

    ## determine if dur has four columns, e.g. 00:01:32:28
    four_col_pattern='^([0-9]{2}:){3}[0-9]{2}$'
    if [[ "$dur" =~ $four_col_pattern ]]; then
        ## remove leading 00: because in durations with four columns, the first one is expected to be always 00
        dur="$(printf '%s\n' "$dur" | sed 's/^00://')"
    fi

    ## 00:00:00 -> 0:00
    reg_pattern_1='^00:00:00$'
    if [[ "$dur" =~ $reg_pattern_1 ]]; then
        printf '0:00'
        return
    fi

    ## 00:00:51 -> 0:51
    reg_pattern_2='^00:00:[0-9]{2}$'
    if [[ "$dur" =~ $reg_pattern_2 ]]; then
        printf '%s\n' "$dur" | sed 's/^00:00:/0:/'
        return
    fi

    ## 00:00 -> 0:00
    ## 00:19 -> 0:19
    reg_pattern_3='^00:[0-9]{2}$'
    if [[ "$dur" =~ $reg_pattern_3 ]]; then
        printf '%s\n' "$dur" | sed 's/^0//'
        return
    fi

    ## 00:03:26 -> 3:26
    ## 04:03:26 -> 4:03:26
    printf '%s\n' "$dur" | sed 's/^[0:]*//'
}
