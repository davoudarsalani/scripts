#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/kaddyify.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/kaddyify.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-color.sh

## --archive, -a            archive mode is -rlptgoD (no -A,-X,-U,-N,-H)
## --recursive, -r          recurse into directories
## --progress               show progress during transfer
## -P                       same as --partial --progress
## --delete                 remove files on remote not present on local
## --dry-run -v, -n -v      perform a trial run with no changes made (-v is added by me)
## --itemize-changes, -i    output a change-summary for all updates

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    kaddyify_help
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,sync,diff,directory:' --options 'hsfd:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -s|--sync )
                flags='--archive --progress --delete' ;;
            -f|--diff )
                ## https://unix.stackexchange.com/questions/57305/rsync-compare-directories
                ## -v not needed here
                flags='--archive --itemize-changes --dry-run' ;;  ## --archive OR --recursive
            -d|--directory )
                shift
                selected_directory="$1"

                reg='^\.$'
                [[ "$selected_directory" =~ $reg ]] && selected_directory="$PWD"

                ## NOTE JUMP_1 remove trailing slash
                ##             important because we want the directory itself
                ##             to be synced/copeid to destination
                ##             rather than its content
                selected_directory="${selected_directory%/}"

                dest_kaddy_dir="$home_kaddy_dir"/"${selected_directory##*/}"  ## ~/kaddy/scripts

                [ -d "$selected_directory" ] || {
                    red "$(to_tilda "$selected_directory") does not exist"
                    exit
                }
                [ -d "$dest_kaddy_dir" ] || {
                    red "$(to_tilda "$dest_kaddy_dir") does not exist"
                    exit
                }

                sync_prompt="$(get_single_input "sync $(to_tilda "$selected_directory") to $(to_tilda "$home_kaddy_dir")?")" && printf '\n'
                [ "$sync_prompt" == 'y' ] || exit
                ;;
            -- )
                break ;;
        esac
        shift
    done
}

home_kaddy_dir=~/kaddy

get_opt "$@"
heading "$title"

[ ! "$1" ] || [ ! "$flags" ] && display_help

if [ "$selected_directory" ]; then
    ## NOTE JUMP_2 keep $flags unquoted
    rsync $flags "$selected_directory" "$home_kaddy_dir" | \grep -v 'incremental file list'
else
    readarray -t kaddy_directories < <(find "$home_kaddy_dir" -mindepth 1 -maxdepth 1 -type d | sort)  ## ! -path '*lost+found*'

    for kaddy_dir in "${kaddy_directories[@]}"; {
        base="${kaddy_dir##*/}"

        ## NOTE JUMP_1 remove trailing slash
        ##             important because we want the directory itself
        ##             to be synced/copeid to destination
        ##             rather than its content
        base="${base%/}"

        home_dir=~/main/"$base"

        blue "$(to_tilda "$home_dir")"

        ## NOTE JUMP_2 keep $flags unquoted
        rsync $flags "$home_dir" "$home_kaddy_dir" | \grep -v 'incremental file list'
    }
fi

exit 0

## Explanation of each bit position and value in rsync's output:
## (https://stackoverflow.com/questions/4493525/what-does-f-mean-in-rsync-logs)
##
## YXcstpoguax  path/to/file
## |||||||||||
## ||||||||||╰- x: The extended attribute information changed
## |||||||||╰-- a: The ACL information changed
## ||||||||╰--- u: The u slot is reserved for future use
## |||||||╰---- g: Group is different
## ||||||╰----- o: Owner is different
## |||||╰------ p: Permission are different
## ||||╰------- t: Modification time is different
## |||╰-------- s: Size is different
## ||╰--------- c: Different checksum (for regular files), or changed value (for symlinks, devices, and special files)
## ||
## |╰----------    file type:
## |            f: for a file,
## |            d: for a directory,
## |            L: for a symlink,
## |            D: for a device,
## |            S: for a special file (e.g. named sockets and fifos)
## |
## ╰-----------    type of update being done:
##              <: file is being transferred to the remote host (sent)
##              >: file is being transferred to the local host (received)
##              c: local change/creation for the item, such as:
##                 - the creation of a directory
##                 - the changing of a symlink,
##                 - etc.
##              h: the item is a hard link to another item (requires --hard-links).
##              .: the item is not being updated (though it might have attributes that are being modified)
##              *: means that the rest of the itemized-output area contains a message (e.g. "deleting")
