#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb.sh
##    https://davoudarsalani.ir

function to_tilda {
    ## - using // to replace all occurrences
    ## - using $@ instead of $1 because arguments
    ##   can be passed as an array
    printf '%s\n' "${@//$HOME/\~}"
}

function get_datetime {
    case "$1" in
            ymdhms )
                printf '%(%Y%m%d%H%M%S)T\n' ;; ## PREVIOUSLY: printf '%s\n' "$(date +%Y%m%d%H%M%S)"
            ymd )
                printf '%(%Y%m%d)T\n' ;; ## PREVIOUSLY: printf '%s\n' "$(date +%Y%m%d)"
            hms )
                printf '%(%H%M%S)T\n' ;; ## PREVIOUSLY: printf '%s\n' "$(date +%H%M%S)"
            seconds )
                printf '%(%s)T\n' ;; ## PREVIOUSLY: printf '%s\n' "$(date +%s)"
            weekday )
                printf '%(%A)T\n' ;; ## PREVIOUSLY: printf '%s\n' "$(date +%A)"
            jymdhms )
                printf '%s\n' "$(jdate +%Y%m%d%H%M%S)" ;;
            jymd )
                printf '%s\n' "$(jdate +%Y%m%d)" ;;
            jhms )
                printf '%s\n' "$(jdate +%H%M%S)" ;;
            jseconds )
                printf '%s\n' "$(jdate +%s)" ;;
            jweekday )
                printf '%s\n' "$(jdate +%A)" ;;
    esac
}

function heading {
    source ~/main/scripts/gb-color.sh

    echo -e "$(green "$@")"  ## JUMP_2 can't use printf as it returns literal foo\nbar if 'foo\nbar' is passed to it
}

function flag {
    source ~/main/scripts/gb-color.sh

    echo -e "$(purple "$@")"  ## JUMP_2 can't use printf as it returns literal foo\nbar if 'foo\nbar' is passed to it
}

function action_now {
    source ~/main/scripts/gb-color.sh

    echo -e "$(green '→') $(gray "$@")"  ## JUMP_2 can't use printf as it returns literal foo\nbar if 'foo\nbar' is passed to it
}

function accomplished {
    source ~/main/scripts/gb-color.sh

    echo -e "$(green '✔') $(gray "$@")"  ## JUMP_2 can't use printf as it returns literal foo\nbar if 'foo\nbar' is passed to it
}

function wrap_fzf_choice {
    source ~/main/scripts/gb-color.sh

    printf '%s %s %s\n' "$(brown '--=[')" "$@" "$(brown ']=--')"
}

function select_file {
    ## NOTE stolen from ~/.fzf/shell/key-bindings.bash with modifications
    ##      any change you make here, make sure to apply the changes there too
    ## NOTE used also in ~/.config/lfrc

    local item

    eval "$FZF_CTRL_T_COMMAND" | sed "s#$HOME#~#" | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" fzf "$@" | \
    while read -r item; do
        item="$(head -2 <<< "$item" | tail -1)"
        printf '%s\n' "${item/\~/$HOME}"
    done
}

function select_directory {
    ## NOTE stolen from ~/.fzf/shell/key-bindings.bash with modifications
    ##      any change you make here, make sure to apply the changes there too
    ## NOTE used also in ~/.config/lfrc

    ## usage: this function can accept two args to limit results
    ##   dir="$(select_directory)"
    ##   dir="$(select_directory 'git')"
    ##   dir="$(select_directory 'git' 'public')"

    local dir

    [ "$1" == 'git' ] && {  ## display git repositories only
        [ "$2" ] && FZF_ALT_C_COMMAND_GIT+=" | \grep "$2""  ## display specific git repositories only
        FZF_ALT_C_COMMAND="$FZF_ALT_C_COMMAND_GIT"
    }

    dir="$(eval "$FZF_ALT_C_COMMAND" | sed "s#$HOME#~#" | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS --header ''" fzf)"
    [ "$dir" ] && printf '%q\n' "${dir/\~/$HOME}"
}

function pipe_to_fzf {
    ## usage:
    ##   item="$(pipe_to_fzf "${items[@]}")"

    if [ "$fzf__title" ]; then
        printf '%s\n' "$@" | fzf --header "$fzf__title"
    else
        printf '%s\n' "$@" | fzf
    fi
}

function pipe_to_dmenu {
    ## usage:
    ##   item="$(pipe_to_dmenu "${items[@]}")"

    printf '%s\n' "$@" | \
    dmenu -i -l "$dmenulines" -nb "$dmenunb" -nf "$dmenunf" -sb "$dmenusb" -sf "$dmenusf" -fn "$dmenufn" -p "$dmenu__title"
}

function pipe_to_rofi__confirm() {
    ## borrowed from ~/main/configs/cfg-rofi/powermenu/type-1/powermenu.sh

    ## usage:
    ##   item="$(pipe_to_rofi__confirm "${items[@]}")"

    local theme_path
    theme_path=~/.config/rofi/powermenu/type-1/style-1.rasi

    printf 'Yes\nNo\n' | \
	rofi -dmenu \
		 -theme "$theme_path" \
         -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 250px;}' \
		 -theme-str 'mainbox {children: [ "message", "listview" ];}' \
		 -theme-str 'listview {columns: 2; lines: 1;}' \
		 -theme-str 'element-text {horizontal-align: 0.5;}' \
		 -theme-str 'textbox {horizontal-align: 0.5;}' \
		 -p 'Confirmation' \
		 -mesg 'Are You Sure?'
}

function pipe_to_rofi {
    ## usage:
    ##   item="$(pipe_to_rofi "${items[@]}")"

    local theme_path
    theme_path=~/.config/rofi/launchers/type-1/style-3.rasi

    ## not adding this line because
    ## it made elements look striped
    # -theme-str "window { background-color: ${gruvbox_bg_d}; }"

    if [ "$rofi__subtitle" ]; then
        printf '%s\n' "$@" | \
        rofi -dmenu \
             -theme "$theme_path" \
             -theme-str 'window { border-radius: 0px; }' \
             -theme-str "prompt { text-color: ${gruvbox_green}; }" \
             -theme-str "inputbar { text-color: ${gruvbox_gray_d}; }" \
             -p "$rofi__title" \
             -mesg "$rofi__subtitle"
    else
        printf '%s\n' "$@" | \
        rofi -dmenu \
             -theme "$theme_path" \
             -theme-str 'window { border-radius: 0px; }' \
             -theme-str "prompt { text-color: ${gruvbox_green}; }" \
             -theme-str "inputbar { text-color: ${gruvbox_gray_d}; }" \
             -p "$rofi__title"
    fi
}

function lsblk_full {
    \lsblk -o NAME,LABEL,SIZE,UUID,FSTYPE,TYPE,MOUNTPOINT,OWNER,GROUP,MODE,MAJ:MIN,RM,RO
}

function mounted_drives {
    if [ "$1" ]; then
        printf '%s\n' "$(df -hT)"
    else
        printf '%s\n' "$(df -T -x devtmpfs -x tmpfs -x usbfs -x loop)"  ## -x ARG instances help get rid of unnecessary drives
    fi
}

function get_mountable_umountable {
    readarray -t mountable  < <(\lsblk -nro NAME,LABEL,SIZE,UUID,FSTYPE,TYPE,MOUNTPOINT | \grep -iE 'part $|rom $' | \grep -viE ' swap part $|^nvme|^sda|^sdb')
    readarray -t umountable < <(\lsblk -nro NAME,LABEL,SIZE,UUID,FSTYPE,TYPE,MOUNTPOINT | \grep -i '/tmp/')
}

function msgn {
    notify-send --urgency=normal "$1" "$2" -i "$3" -t 10000
}

function msgc {
    notify-send --urgency=critical "$1" "$2" -i "$3"
}

function clear_playlist {
    audtool --playlist-clear
}

function turn_off_shuffle {
    source ~/main/scripts/gb-audacious.sh
    [ "$shuffle_status" == 'on'  ] && audtool --playlist-shuffle-toggle
}

function turn_on_shuffle {
    source ~/main/scripts/gb-audacious.sh
    [ "$shuffle_status" == 'off' ] && audtool --playlist-shuffle-toggle
}

function play_shutdown_track {
    source ~/main/scripts/gb-audio.sh
    pacmd play-file ~/main/configs/sounds/shutdown.ogg "$def_sink_index"
}

function relative_date {
    ## usage:
    ##   relative_date '2019-05-03T07:07:11Z'
    ##   relative_date 1556867231

    local start_date_in_seconds now_in_seconds

    if [ "$1" -eq "$1" ] 2>/dev/null; then
        start_date_in_seconds="$1"
    else
        start_date_in_seconds="$(convert_to_second "$1")"
    fi

    now_in_seconds="$(get_datetime 'seconds')"

    printf '%s ago\n' "$(convert_second "(( now_in_seconds - start_date_in_seconds ))" 'verbose')"
}

function convert_to_second {  ## convert 2021-04-15T11:10:03+0430 to 1618468803
    printf '%s\n' "$(date --date "$1" '+%s')"
}

function convert_second {
    local seconds sec min hour day mont year result

    seconds="${1%.*}"  ## remove decimal in case arg is a float

    if (( seconds < 1 )); then
        if [ "$2" == 'verbose' ]; then
            result="less than a second"
        else
            result="00:00:00"
        fi
    else
        sec="$(printf  "%02d" "$(( "$seconds" % 60 ))")"
        min="$(printf  "%02d" "$(( "$seconds" / 60 % 60 ))")"
        hour="$(printf "%02d" "$(( "$seconds" / 3600 % 24 ))")"
        day="$(printf  "%02d" "$(( "$seconds" / 3600 / 24 % 30 ))")"
        mont="$(printf "%02d" "$(( "$seconds" / 3600 / 24 / 30 % 12 ))")"
        year="$(printf "%02d" "$(( "$seconds" / 3600 / 24 / 30 / 12 ))")"

        ## NOTE used [ "$var" -eq 0 ] instead of (( var == 0 )) because
        ##      1. (( var == 0 )) is stupid (i.e. it returns true even if var does not exist)
        ##      2. ints here are two-digit and (( var == 0 )) can't handle that
        if [ "$year" -eq 0 ] && [ "$mont" -eq 0 ] && [ "$day" -eq 0 ]; then
            if [ "$2" == 'verbose' ]; then
                result="$hour hours, $min minutes and $sec seconds"
            else
                result="${hour}:${min}:${sec}"
            fi
        elif [ "$year" -eq 0 ] && [ "$mont" -eq 0 ]; then
            if [ "$2" == 'verbose' ]; then
                result="$day days, $hour hours, $min minutes and $sec seconds"
            else
                result="${day}:${hour}:${min}:${sec}"
            fi
        elif [ "$year" -eq 0 ]; then
            if [ "$2" == 'verbose' ]; then
                result="$mont months, $day days, $hour hours, $min minutes and $sec seconds"
            else
                result="${mont}:${day}:${hour}:${min}:${sec}"
            fi
        else
            if [ "$2" == 'verbose' ]; then
                result="$year years, $mont months, $day days, $hour hours, $min minutes and $sec seconds"
            else
                result="${year}:${mont}:${day}:${hour}:${min}:${sec}"
            fi
        fi


        ## NOTE the same modifications in JUMP_4 are applied in
        ##        1. convert_second function in gb.py
        ##        2. 'relative' method of whatever-its-name-is class in models.py in django app
        ##      so any changes you make here, make sure to update them too

        ## JUMP_4 remove items whose values are 00, and adjust comma and 'and'
        result="$(printf '%s\n' "$result" | \
            sed 's|00 [a-z]\+s, ||g' | \
            sed 's|00 [a-z]\+s and ||' | \
            sed 's|00 [a-z]\+s$||' | \
            sed 's|, \([0-9][0-9] [a-z]\+s \)| and \1|' | \
            sed 's|and 00 [a-z]\+s ||' | \
            sed 's| and $||' | \
            sed 's|, \([0-9][0-9] [a-z]\+\)$| and \1|' | \
            sed 's| and \([0-9][0-9] [a-z]\+\) and|, \1 and|g' | \
            sed 's|, \+$||' | \
            sed 's|, \([0-9][0-9] [a-z]\+s\)$| and \1|' \
        )"

        ## JUMP_4 remove plural s when value is 01
        result="$(printf '%s\n' "$result" | sed 's|\(01 [a-z]\+\)s |\1 |g;s|\(01 [a-z]\+\)s, |\1, |g;s|\(01 [a-z]\+\)s$|\1|')"

    fi

    printf '%s\n' "$result"
}

function insert_comma {
    printf "%'d\n" "$1"
}

function greenclip_clear {
    greenclip clear
    msgn 'cleared' '' ~/main/configs/themes/greenclip.png
}

function random_wallpaper {
    local current_wallpaper_file rand_wall

    current_wallpaper_file=/tmp/current_wallpaper
    ## same wallpaper for both screens
    rand_wall="$(shuf -n 1 < <(find ~/main/wallpapers -mindepth 1 -maxdepth 1 -type f -iname '*.jpg'))"  ## JUMP_1
    printf '%s\n' "${rand_wall##*/}" > "$current_wallpaper_file"
    feh --bg-scale "$rand_wall"
}

function copy_random_wallpaper_for_startup {
    source ~/main/scripts/gb-color.sh
    local rand_wall dest_dir

    rand_wall="$(shuf -n 1 < <(find ~/main/wallpapers -mindepth 1 -maxdepth 1 -type f -iname '*.jpg'))"  ## JUMP_1

    dest_dir=/usr/share/wallpapers
    [ -d "$dest_dir" ] || sudo mkdir "$dest_dir"

    sudo cp "$rand_wall" "$dest_dir"/startup_background.jpg && \
    msgn "<span color=\"${gruvbox_orange}\">${rand_wall##*/}</span> copied"
}

function set_widget {
    ## only the awesome-widgets use this function but it'd better be here (rather than the script itself)
    ## because sometimes it's needed by 0-test

    local widget attr value

    widget="$1"
    attr="$2"
    value="$3"

    awesome-client "${widget}.${attr} = '${value}'"  ## NOTE do NOT change quotes
}

function get_input {
    source ~/main/scripts/gb-color.sh
    local input

    unset input
    read -p "$(olive "$@") " input
    printf '%s\n' "$input"
}

function get_single_input {
    source ~/main/scripts/gb-color.sh
    local single_input

    unset single_input
    read -p "$(olive "$@") " -n 1 single_input
    printf '%s\n' "$single_input"
}

function line {
    source ~/main/scripts/gb-color.sh

    gray "$(printf "%$(tput cols)s\n" | sed "s/ /▬/g")"
}

function rand_str {
    printf '%s\n' "$(mktemp --dry-run | sed 's/.*\.//g')"  ## returns e.g. leQPAUyfZP

    # sed 's/-//g' < /proc/sys/kernel/random/uuid  ## returns e.g. a8a29c0d109a40468051bcbaf70af17e
}

function get_kaddy_counterpart {
    printf '%s\n' "$(sed -e "s|\($HOME\)/main\(\)|\1/kaddy\2|" <<< "$1")"
}

function remove_older_pkgs {
    source ~/main/scripts/gb.sh
    source ~/main/scripts/gb-color.sh

    local src_dir uniq count file exceed idx remove_propmt
    declare -a files uniques repeats to_be_removed
    declare -i keep=2

    src_dir=~/main/linux-pkg
    readarray -t files < <(find "$src_dir" -mindepth 1 -maxdepth 1 -type f ! -iname '*.sig' ! -iname '*:*' | sort)
    readarray -t uniques < <(printf '%s\n' "${files[@]}" | sed 's|-[0-9]\+[^:]*||g' | sort | uniq --count)
    for uniq in "${uniques[@]}"; {
        read count file <<< "$uniq"  ## 8 /home/nnnn/main/linux-pkg/alsa-card-profiles
        (( count <= keep )) && continue
        (( exceed="count - keep" ))  ## 5
        readarray -t repeats < <(find "$src_dir" -mindepth 1 -maxdepth 1 -type f -iname "${file##*/}*" ! -iname '*.sig' ! -iname '*:*' | sort)
        for ((idx=0; idx<${exceed}; idx++)); {
            to_be_removed+=( "${repeats[${idx}]}" )
        }
    }

    if [ "$to_be_removed" ]; then
        printf '%s\n' "${to_be_removed[@]##*/}" | sort | column
        remove_propmt="$(get_single_input "remove ${#to_be_removed[@]} pkgs?")" && printf '\n'
        case "$remove_propmt" in
            y )
                action_now "removing from $(to_tilda "$src_dir")"
                rm -v "${to_be_removed[@]}"
                ;;
        esac
    else
        red 'nothing to remove'
    fi
}

function expand_ips_from_ranges {
    source ~/main/scripts/gb-color.sh
    local ip1 ip2 dest_file ip1_4_new
    local ip1_1 ip1_2 ip1_3 ip1_4 ip2_1 ip2_2 ip2_3 ip2_4

    [ "$3" ] || {
        red "args needed"
        red "USAGE: $FUNCNAME <IP1> <IP2> ~/main/downloads/ip_ranges.py "
        exit
    }

    [ -f "$3" ] && {
        red "$3 already exists"
        exit
    }

    ip1="$1"
    ip2="$2"
    dest_file="$3"

    ip1_1="$( printf '%s\n' "$ip1" | cut -f 1 -d '.' )"
    ip1_2="$( printf '%s\n' "$ip1" | cut -f 2 -d '.' )"
    ip1_3="$( printf '%s\n' "$ip1" | cut -f 3 -d '.' )"
    ip1_4="$( printf '%s\n' "$ip1" | cut -f 4 -d '.' )"

    ip2_1="$( printf '%s\n' "$ip2" | cut -f 1 -d '.' )"
    ip2_2="$( printf '%s\n' "$ip2" | cut -f 2 -d '.' )"
    ip2_3="$( printf '%s\n' "$ip2" | cut -f 3 -d '.' )"
    ip2_4="$( printf '%s\n' "$ip2" | cut -f 4 -d '.' )"

    printf 'ips = {\n' > "$dest_file"
    while (( ip1_3 <= ip2_3 )); do
        ip1_4_new="$ip1_4"
        while (( ip1_4_new <= ip2_4 )); do
            # printf '%s %s\n' "$ip1_3" "$ip1_4_new"
            printf "\t'%s.%s.%s.%s',\n" "$ip1_1" "$ip1_2" "$ip1_3" "$ip1_4_new" >> "$dest_file"
            ((ip1_4_new++))
        done
        ((ip1_3++))
    done
    printf '}\n' >> "$dest_file"
}

function shutdown_now {
    shutdown -h now
}

function reboot_now {
    shutdown -r now
}

function quit_awesome_now {
    awesome-client 'awesome.quit()'
}

function restart_awesome_now {
    ## NOTE do NOT remove the () in restart.
    ## Originally, () is not required in rc.lua
    awesome-client 'awesome.restart()'
}

function turn_screen_off_now {
    xset dpms force off
}

function lock_now {
    dm-tool lock
}

# function find_duplicate_images {
#     [ "$1" ] || {
#         red 'two args needed:'
#         red "usage: $FUNCNAME SRC_DIR_PATH FILE_EXTENSION (e.g. json)"
#         exit
#     }

#     dest_dir="$1"
#     [ -d "$dest_dir" ] || {
#         red "no such dir as ${dest_dir}"
#         exit
#     }

#     dups_file=/tmp/duplicates-"$(date '+%s')"
#     dups_string=''
#     declare -A dups_array

#     readarray -t files < <(find "$1" -mindepth 1 -type f -iname "*.${2}" | sort)
#     orig_count="${#files[@]}"

#     for ((idx=0; idx<"${orig_count}"; idx++)); {
#         f_1="${files[$idx]}"

#         ## skip comparing if f_1 is already in dups_string
#         \grep -q "$f_1" <<< "$dups_string" && continue

#         printf '%s/%s %s\n' "$((idx+1))" "${orig_count}" "$f_1"
#         for f_2 in "${files[@]}"; {
#             ## prevent comparing with itself
#             [ "$f_1" == "$f_2" ] || {
#                 [ "$(diff "$f_1" "$f_2")" ] || {
#                     printf '%s\n%s removed\n\n' "$f_1" "$f_2" >> "$dups_file"
#                     dups_string+="${f_1} ${f_2} "
#                     dups_array+=([${f_1}]="$f_2")
#                 }
#             }
#         }
#         unset "files[${idx}]"
#         (( "${#dups_array[@]}" > 0 )) && printf '  -> %s found\n' "${#dups_array[@]}"
#     }

#     ## printf duplicates if any
#     if (( "${#dups_array[@]}" > 0 )); then  ## NOTE dups_array is an associative array and '[ "$dups_array" ] &&' didn't work to check if it's full
#         printf '\n\n %s set(s) of duplicates found (file names also saved at %s):\n\n' "${#dups_array[@]}" "$dups_file"
#         for key in "${!dups_array[@]}"; {
#             rm "${dups_array[${key}]}"
#             printf '%s\n%s removed\n\n' "$key" "${dups_array[${key}]}"
#         }
#     else
#         printf '\nok\n'
#     fi
# }

# function compare_network_speed {
#    ## this function takes only one arg which can only be either old or new

#    source ~/main/scripts/gb-calculation.sh
#    source ~/main/scripts/gb-color.sh

#    declare -a loop_durs loops_durs

#    durs_file=/tmp/0-durs
#    totals_file=/tmp/0-totals
#    loops_count=10
#    position="$1"

#    [ "$position" == 'old' ] || [ "$position" == 'new' ] || {
#        printf '%s\n' "$(red "arg can only be either old or new")"
#        exit
#    }

#    ## if position is old it means we want to have a fresh start
#    ## so let's empty totals_file first
#    [ "$position" == "old" ] && > "$totals_file"

#    for ((i=1; i<="$loops_count"; i++)); {
#        printf 'loop %s\n' "$i"
#        > "$durs_file"
#        for ((j=1; j<="$loops_count"; j++)); {
#            { time -p ~/main/scripts/awesome-widgets network ;} &>>"$durs_file"
#            printf '\n' >> "$durs_file"
#            sleep 1
#        }

#        loop_dur=0
#        readarray -t loop_durs < <(\grep 'real' "$durs_file" | awk '{print $NF}')
#        for a_sm in "${loop_durs[@]}"; {
#            loop_dur="$(float_pad "${loop_dur}+${a_sm}" 1 2)"
#        }
#        printf '%s %s\n' "$position" "$loop_dur" >> "$totals_file"
#    }

#    loops_dur=0
#    readarray -t loops_durs < <(\grep "$position" "$totals_file" | awk '{print $NF}')
#    for a_big in "${loops_durs[@]}"; {
#        loops_dur="$(float_pad "${loops_dur}+${a_big}" 1 2)"
#    }
#    printf '%s = %s\n\n' "$position" "$loops_dur" >> "$totals_file"

#    ## compare
#    old_loops_total="$(\grep 'old =' "$totals_file" | awk '{print $NF}' 2>/dev/null)"
#    new_loops_total="$(\grep 'new =' "$totals_file" | awk '{print $NF}' 2>/dev/null)"

#    [ "$new_loops_total" ] && [ "$old_loops_total" ] && {
#        is_faster="$(compare_floats "$new_loops_total" '<' "$old_loops_total")"
#        is_slower="$(compare_floats "$new_loops_total" '>' "$old_loops_total")"
#        if [ "$is_faster" == 'true' ]; then
#            diff="$(float_pad "${old_loops_total}-${new_loops_total}")"
#            msg="$diff faster"
#        elif [ "$is_slower" == 'true' ]; then
#            diff="$(float_pad "${new_loops_total}-${old_loops_total}")"
#            msg="$diff slower"
#        else
#            msg="$old_loops_total = $new_loops_total"
#        fi
#        printf 'compare\n%s\n' "$msg" >> "$totals_file"
#    }
# }

## timer and record_*
# function timer {
#     source ~/main/scripts/gb-color.sh
#     source ~/main/scripts/gb-screen.sh
#     source ~/main/scripts/gb-audio.sh
#     start="$(get_datetime 'jhms')"
#     for ((i=1; i<="$1"; i++)); {
#         current="$(get_datetime 'jhms')"
#         (( seconds="current - start" ))
#         echo -en '\r  \r'
#         (( h="seconds / 3600 % 24" ))
#         (( m="seconds / 60 % 60" ))
#         (( s="seconds % 60" ))
#         w="$(printf "$2 %02d:%02d:%02d" "$h" "$m" "$s"  ## NOTE no \n ??
#         set_widget 'record' 'markup' "<span color=\"${gruvbox_red}\">${record_icon} <b>${w}</b></span>"
#         sleep 1
#     }
# }

# function record_audio {
#     source ~/main/scripts/gb-screen.sh
#     source ~/main/scripts/gb-audio.sh
#     timer "$3" "$4" &
#     ffmpeg -f pulse -i "$def_source_mon_index" \
#            -f pulse -i default                \
#            -filter_complex amix=inputs=2      \
#            -t "$1" "$2" 2>/dev/null
# }

# function record_audio_ul {
#     source ~/main/scripts/gb-screen.sh
#     source ~/main/scripts/gb-audio.sh
#     ffmpeg -f pulse -i "$def_source_mon_index" \
#            -f pulse -i default \
#            -filter_complex amix=inputs=2 \
#            "$1" 2>/dev/null
# }

# function record_screen {
#     source ~/main/scripts/gb-screen.sh
#     timer "$3" "$6" &
#     ffmpeg -f pulse -i "$def_source_mon_index" \
#            -f pulse -i default \
#            -filter_complex amix=inputs=2 \
#            -f x11grab -r 30 -s "$4" -i :0.0+"$5",0 \
#            -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 -pix_fmt yuv420p \
#            -t "$1" "$2" 2>/dev/null
# }

# function record_screen_ul {
#     source ~/main/scripts/gb-screen.sh
#     source ~/main/scripts/gb-audio.sh
#     ffmpeg -f pulse -i "$def_source_mon_index" \
#            -f pulse -i default \
#            -filter_complex amix=inputs=2 \
#            -f x11grab -r 30 -s "$2" -i :0.0+"$3",0 \
#            -vcodec libx264 -preset veryfast -crf 18 -acodec libmp3lame -q:a 1 -pix_fmt yuv420p \
#            "$1" 2>/dev/null
# }

# function record_video {
#     source ~/main/scripts/gb-screen.sh
#     source ~/main/scripts/gb-audio.sh
#     timer "$3" "$4" &
#     ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i "$def_video_dev" \
#            -f pulse -i "$def_source_mon_index" \
#            -f pulse -i default \
#            -filter_complex amix=inputs=2 \
#            -t "$1" "$2" 2>/dev/null
# }

# function record_video_ul {
#     source ~/main/scripts/gb-screen.sh
#     source ~/main/scripts/gb-audio.sh
#     ffmpeg -f v4l2 -framerate 25 -video_size 1366x768 -i "$def_video_dev" \
#            -f pulse -i "$def_source_mon_index" \
#            -f pulse -i default \
#            -filter_complex amix=inputs=2 \
#            "$1" 2>/dev/null
# }

# function record_mic_mon_on {
#     source ~/main/scripts/gb-audio.sh
#     unmute_mic
#     mic_25
#     unmute_mon
#     mon_100
# }

# function record_mon_on {
#     source ~/main/scripts/gb-audio.sh
#     unmute_mon
#     mon_100
# }

# function record_mic_mon_off {
#     source ~/main/scripts/gb-audio.sh
#     mute_mic
#     mic_0
#     mute_mon
#     mon_0
# }
