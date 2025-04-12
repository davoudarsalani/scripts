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

    readarray -t files < <(find "$dest_dir" -mindepth 1 -maxdepth 1 ! -iname '*00-note' | sort)
    printf '%s\n' "${files[@]##*/}" | column

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

main_items=( 'visual-studio-code' 'sublime' 'awesome' 'yazi' 'bash' 'tmux' 'fzf' 'mimeapps.list' 'xfce4-terminal' 'vim' 'rofi' 'greenclip' 'grub' 'lightdm' 'highlight' 'audacious' 'vlc' 'git' 'tor' 'torsocks' 'ssh' 'optimus-manager' 'pacman.conf' 'gtk-2.0' 'gtk-3.0' 'fstab' 'xorg.conf' 'xinitrc' 'mirrorlist' 'hosts'  'service' '/var/cache/pacman/pkg' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

dest_dir=~/main/configs/cfg-"$main_item"

case "$main_item" in
    visual-studio-code )
        copy ~/.config/Code/User/*.json \
             ~/.config/Code/User/snippets ;;
    sublime )
        copy ~/.config/sublime-text/* ;;
    awesome )
        copy ~/.config/awesome/* ;;
    yazi )
        copy ~/.config/yazi/* ;;
    bash )
        copy ~/.bashrc \
             ~/.bash_history \
             /etc/{bash.bashrc,environment,inputrc,profile} ;;
    tmux )
        copy ~/.tmux* ;;
    fzf )
        copy ~/.fzf/ ;;
    mimeapps.list )
        copy ~/.config/mimeapps.list ;;
    # lf )
    #     copy ~/.config/lf/lfrc \
    #          ~/.local/share/lf/{marks,history} ;;
    # ranger )
    #     ## first, check if the version of os python and ranger python are different
    #     ranger_python="$(ranger --version | \grep -i 'python version' | awk '{print $3}')"
    #     os_python="$(python --version | awk '{print $NF}')"
    #     [ "$os_python" == "$ranger_python" ] || {
    #         red "different python versions. ranger python: ${ranger_python}, os python: ${os_python})"
    #         exit
    #     }

    #     ## now check if python version has changed from 3.9.*
    #     regex='3.9.*'
    #     [[ "$os_python" =~ $regex ]] || {
    #         red "python version changed ($os_python)"
    #         exit
    #     }

    #     copy ~/.config/ranger/{colorschemes,plugins,commands.py,commands_full.py,rc.conf,rifle.conf,scope.sh} \
    #          /usr/lib/python3.9/site-packages/ranger/container/fsobject.py ;;
    xfce4-terminal )
        copy ~/.config/xfce4/* ;;
    vim )
        copy ~/{.vim,.vimrc} ;;
    rofi )
        copy ~/.config/rofi/* \
             ~/shared ;;
    greenclip )
        copy ~/.config/greenclip.toml ;;
    grub )
        copy /etc/default/grub ;;
    lightdm )
        copy /etc/lightdm/* ;;
    highlight )
        copy ~/.config/highlight/anotherdark.theme \
             /usr/share/highlight/* ;;
    audacious )
        copy ~/.config/audacious/* ;;
    vlc )
        copy ~/.config/vlc/* ;;
    git )
        copy ~/{.gitconfig,.git-credentials} ;;
    tor )
        copy /etc/tor/torrc ;;
    torsocks )
        copy /etc/tor/torsocks.conf ;;
    ssh )
        copy /etc/ssh/{ssh_config,sshd_config} \
             ~/.ssh/{config,id_rsa*,known_hosts*} ;;
    optimus-manager )
        copy /etc/optimus-manager/optimus-manager.conf \
             /etc/X11/xorg.conf.d/10-optimus-manager.conf ;;
    ## os pkgs ----------------------------------------------------------------
    pacman.conf )
        copy /etc/pacman.conf ;;
    gtk-2.0 )
        [ -f ~/.gtkrc-2.0 ] || {
            red "~/.gtkrc-2.0 does not exist"
            exit
        }

        copy ~/.gtkrc-2.0 \
             ~/.config/gtk-2.0/gtkfilechooser.ini ;;
    gtk-3.0 )
        copy ~/.config/gtk-3.0/* ;;
    fstab )
        copy /etc/fstab ;;
    xorg.conf )
        copy /etc/X11/xorg.conf ;;
    xinitrc )
        copy ~/.xinitrc ;;
    mirrorlist )
        copy /etc/pacman.d/mirrorlist ;;
    hosts )
        copy /etc/hosts ;;



    ## pkgs with exceptional removing/copying procedures -------------------------------

    ## copies specific files
    service )
        action_now 'copying bestoon.service'
        cp /etc/systemd/system/bestoon.service "$dest_dir" && accomplished ;;

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
