#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/pulseaudio.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/pulseaudio.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-audio.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    pulseaudio_help
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -d ) default="${default:-"$(get_input 'default sink/source index/name')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,default:' --options 'hd:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -d|--default )
                shift
                default="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

main_items=( 'cards' 'sinks/sources' 'default sink/source/mon' 'all levels + mute status' 'active sink/source port' 'app responsible for sound card' 'apps using sink/source' 'set default sink/source' 'restart' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    cards )
        pacmd list-cards && accomplished ;;
    'sinks/sources' )
        pacmd list-sinks | grep -Ei 'index:|name:'  ## OR  printf '%s\n' "$(pacmd list-cards | \grep -iA 5 sinks | sed '/sources/q' | \grep -Eiv 'sinks|sources' | cut -d '#' -f 2 | cut -c 1)
        pacmd list-sources | grep -Ei 'index:|name:' && accomplished ;;  ## OR  printf '%s\n' "$(pacmd list-cards | \grep -iA 5 sources | sed '/ports/q' | \grep -Eiv 'sources|ports' | cut -d '#' -f 2 | cut -c 1)
    'default sink/source/mon' )
        printf 'default sink name:\t%s\n' "$def_sink_name"
        printf 'default sink index:\t%s\n' "$def_sink_index"
        printf 'default source name:\t%s\n' "$def_source_name"
        printf 'default source index:\t%s\n' "$def_source_index"
        printf 'default mon name:\t%s\n' "$def_source_mon_name"
        printf 'default mon index:\t%s\n' "$def_source_mon_index" && accomplished ;;
    'all levels + mute status' )
        printf '%s\n' \
"Vol
name:   ${def_sink_name}
index:  ${def_sink_index}
level:  ${vol_level}
state:  ${vol_state}
mute:   ${vol_mute_status}

Mic
name:   ${def_source_name}
index:  ${def_source_index}
level:  ${mic_level}
state:  ${mic_state}
mute:   ${mic_mute_status}

Mon
name:   ${def_source_mon_name}
index:  ${def_source_mon_index}
level:  ${mon_level}
state:  ${mon_state}
mute:   ${mon_mute_status}

Active ports
sink:   ${active_sink_port}
source: ${active_source_port}"
        ;;
    'active sink/source port' )
        printf 'active sink port:\t%s\n' "$active_sink_port"
        printf 'active source port:\t%s\n' "$active_source_port" && accomplished ;;
    'app responsible for sound card' )
        ## application which is responsible for a direct access to the sound card via alsa
                                       fuser -v /dev/snd/* && accomplished ;;
    'apps using sink/source' )
        printf 'apps using sink:\n'
                               pacmd list-sink-inputs | \grep -i 'application.name =' | \grep -ioP '(?<=").*?(?=")'
                               printf 'apps using source:\n'
                               pacmd list-source-outputs && accomplished ;;
    'set default sink/source' )
        defaults=( 'set default sink' 'set default source' )
            fzf__title=''
            default="$(pipe_to_fzf "${defaults[@]}")" && wrap_fzf_choice "$default" || exit 37

            case "$default" in
                'set default sink' )
                    prompt -d
                    pacmd set-default-sink "$default" && accomplished ;;
                'set default source' )
                    prompt -d
                    pacmd set-default-source "$default" && accomplished ;;
            esac ;;
    restart )
        restart_prompt="$(get_single_input 'you sure?')" && printf '\n'
            case "$restart_prompt" in
                y )
                    pulseaudio --kill && \
                    sleep 1 && \
                    pulseaudio --start && \
                    msgn 'pulseaudio restarted' && \
                    accomplished ;;
            esac ;;
    help )
        display_help ;;
esac
