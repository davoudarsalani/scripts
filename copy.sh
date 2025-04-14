#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/copy.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/copy.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-color.sh

title="${0##*/}"

function copy {
    local remove_propmt

    action_now 'removing'

    [ -d "$dest_dir" ] || {
        red "no such dir as $dest_dir"
        exit
    }

    ## NOTE *00-note -> *00-*
    ##      to also exclude other files
    ##      and prevent their deletion
    readarray -t files < <(find "$dest_dir" -mindepth 1 -maxdepth 1 ! -iname '*00-*' | sort)
    printf '%s\n' "${files[@]##*/}" # | column

    remove_propmt="$(get_single_input 'remove these?')" && printf '\n'
    case "$remove_propmt" in
        y )
            rm -rf "${files[@]}" ;;
        * )
            exit ;;
    esac

    action_now 'copying'
    cp -r "$@" "$dest_dir" && \
    accomplished
}

heading "$title"

main_items=(
    'awesome'
    'bash'
    'fzf'
    'git'
    'greenclip'
    'mimeapps.list'
    'mysql'
    'optimus-manager'
    'rofi'
    'ssh'
    'sublime'
    'tmux'
    'tor'
    'torsocks'
    'visual-studio-code'
    'yazi'

    'grub'
    'hosts'
    'xorg.conf'

    '/var/cache/pacman/pkg'
)

fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

dest_dir=~/main/configs/cfg-"$main_item"

case "$main_item" in
    awesome )
        copy ~/.config/awesome/* ;;

    bash )
        copy ~/.bashrc \
             ~/.bash_history \
             /etc/{bash.bashrc,environment,inputrc,profile} ;;

    fzf )
        copy ~/.fzf/ ;;

    git )
        copy ~/{.gitconfig,.git-credentials} ;;

    greenclip )
        copy ~/.config/greenclip.toml ;;

    mimeapps.list )
        copy ~/.config/mimeapps.list ;;

    mysql )
        copy /etc/my.cnf ;;

    optimus-manager )
        copy /etc/optimus-manager/optimus-manager.conf \
             /etc/X11/xorg.conf.d/10-optimus-manager.conf ;;

    rofi )
        copy ~/.config/rofi/* \
             ~/shared ;;

    ssh )
        copy /etc/ssh/{ssh_config,sshd_config} \
             ~/.ssh/{config,id_rsa*,known_hosts*} ;;

    sublime )
        copy ~/.config/sublime-text/* ;;

    tmux )
        copy ~/.tmux* ;;

    tor )
        copy /etc/tor/torrc ;;

    torsocks )
        copy /etc/tor/torsocks.conf ;;

    visual-studio-code )
        copy ~/.config/Code/User/*.json \
             ~/.config/Code/User/snippets ;;

    yazi )
        copy ~/.config/yazi/* ;;


    ## ----------------
    ## os pkgs

    grub )
        copy /etc/default/grub ;;

    hosts )
        copy /etc/hosts ;;

    xorg.conf )
        copy /etc/X11/xorg.conf ;;

    ## ----------------
    ## pkgs with exceptional removing/copying procedures

    ## has a different dest_dir
    /var/cache/pacman/pkg )
        dest_dir=~/main/linux-pkg
        readarray -t pkgs < <(find /var/cache/pacman/pkg/ -mindepth 1 -maxdepth 1 -type f)
        if [ "$pkgs" ]; then
            action_now "copying from /var/cache/pacman/pkg to $(to_tilda "$dest_dir")"
            cp -r "${pkgs[@]}" "$dest_dir"

            action_now 'removing pkgs in /var/cache/pacman/pkg'
            sudo rm "${pkgs[@]}"

            action_now 'checking if there are older pkgs to remove'
            remove_older_pkgs
        else
            red 'nothing to copy'
        fi && accomplished ;;
esac
