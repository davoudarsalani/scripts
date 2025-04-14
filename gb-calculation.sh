#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-calculation.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-calculation.sh
##    https://davoudarsalani.ir

function float_pad {
    local input new_l_length new_r_length floated l r r_length lacking_pad

    input="$1"              ## an int, floated or expression, e.g. 43, 6.82, or "${var}*932/12" (no spaces allowd in expression)
    new_l_length="${2:-1}"  ## min   length for l, e.g. 1
    new_r_length="${3:-2}"  ## exact length for r, e.g. 2

    if [[ "$input" =~ ^[+-]?[0-9]+\.[0-9]*$ ]]; then  ## https://stackoverflow.com/questions/13790763/bash-regex-to-check-floating-point-numbers-from-user-input
        floated="$input"  ## 43.76
    else
        ## make input a float even if it is an int or an expression (https://www.shell-tips.com/bash/math-arithmetic-calculation)
        ## NOTE this converting should not be applied on $input if it is already a float
        ##      because it will turn 12.3456 into 12.35 (i.e. will make it rounded)
        floated="$(awk "BEGIN {printf \"%.${new_r_length}f\n\", $input}")"  ## 43 to 43.00
    fi

    ## separate l and r
    l="${floated%.*}"  ## 8
    r="${floated#*.}"  ## 123

    ## make l have the same length as new_l_length
    l="$(printf "%0${new_l_length}d" "$l")"  ## 8 to 08

    ## make r have the same length as new_r_length
    r_length="${#r}"
    if (( new_r_length > r_length )); then  ## add trailing zeros to r if shorter than new_r_length
        (( lacking_pad="new_r_length - r_length" ))
        for ((i=0; i<"$lacking_pad"; i++)); {
            r="${r}0"
        }
    elif (( new_r_length < r_length )); then  ## trim r if longer than new_r_length
        r="${r::$new_r_length}"
    fi

    if [ "$new_l_length" == 0 ]; then
        printf '0\n'
    else
        if [ "$new_r_length" == 0 ]; then
            r=""
        elif [ "$4" == 'keep_zero_right_pad' ]; then
            r=".${r}"  ## return r as is (i.e. whether it's 345 or 00)
        else
            zeros_regex='^0+$'
            if [[ "$r" =~ $zeros_regex ]]; then
                r=""  ## return nothing if r is all zeros (e.g. 00)
            else
                r=".${r}"
            fi
        fi

        printf '%s%s\n' "$l" "$r"
    fi
}

function compare_floats {
    ## https://stackoverflow.com/questions/8654051/how-to-compare-two-floating-point-numbers-in-bash
    ## usage: is_smaller="$(compare_floats "$first" '<' "$second")"  ## returns true or false

    local float1 float2 oper

    float1="$1"
    oper="$2"
    float2="$3"

    ## validate floatness
    # [[ "$float1" =~ ^-*[[:digit:]]*[.][[:digit:]]* ]] || float1="$(float_pad "$float1" 2 2)"
    # [[ "$float2" =~ ^-*[[:digit:]]*[.][[:digit:]]* ]] || float2="$(float_pad "$float2" 2 2)"

    ## compare
    case "$oper" in
         '<' )
            [ "$(awk '{printf($1 <  $2) ? "Yes" : "No"}' <<< "$float1 $float2")" == 'Yes' ] && printf 'true\n' || printf 'false\n' ;;
         '=' )
            [ "$(awk '{printf($1 == $2) ? "Yes" : "No"}' <<< "$float1 $float2")" == 'Yes' ] && printf 'true\n' || printf 'false\n' ;;
         '>' )
            [ "$(awk '{printf($1 >  $2) ? "Yes" : "No"}' <<< "$float1 $float2")" == 'Yes' ] && printf 'true\n' || printf 'false\n' ;;
    esac
}

function convert_byte {
    local size

    size="$1"
    new_l_length="${2:-1}"
    new_r_length="${3:-2}"

    for unit in B K M G T P E Z Y; {
        (( "${size%.*}" < byte_size )) && {
            printf '%s%s\n' "$size" "$unit"
            break
        }
        size="$(float_pad "${size//[a-zA-Z]/}/${byte_size}" "$new_l_length" "$new_r_length")"
    }
}
