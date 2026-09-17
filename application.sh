#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/application.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/application.sh
##    https://davoudarsalani.ir


source ~/main/scripts/helps.sh
source ~/main/scripts/utils.sh
source ~/main/scripts/utils-color.sh

title="$(basename "$0")"

function get_dir_size {
    du -sh "$1" | awk '{print $1}'  ## 52K
}

heading "$title"

main_items=( 'install' 'remove' 'search' 'packages' 'clear junks and clipboard' 'update' 'help' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    install )
        install_items=( 'pacman' 'yay' 'yay + torsocks' 'download (no install)' )
        install_item="$(pipe_to_fzf "${install_items[@]}")" && wrap_fzf_choice "$install_item" || exit 37

        case "$install_item" in
            pacman )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S --needed ;;
            yay )
                ## --nodiffmenu --noeditmenu
                yay -Slq | fzf --preview 'yay -Si {1}' | xargs -ro yay --sortby name --topdown -a --answerclean All --removemake && accomplished ;;
            'yay + torsocks' )
                ## --nodiffmenu --noeditmenu
                yay -Slq | fzf --preview 'yay -Si {1}' | xargs -ro torsocks yay --sortby name --topdown -a --answerclean All --removemake && accomplished ;;
            'download (no install)' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro sudo pacman -Sw && accomplished ;;
        esac ;;

    remove )
        remove_items=( 'normal' 'with all dependencies' 'forceful' 'yay' )
        remove_item="$(pipe_to_fzf "${remove_items[@]}")" && wrap_fzf_choice "$remove_item" || exit 37

        case "$remove_item" in
            normal )
                pacman -Qq | fzf --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns && accomplished ;;  ## s removes dependencies not being used by other packages, and n removes package configuration files
            'with all dependencies' )
                pacman -Qq | fzf --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rnsc && accomplished ;;  ## Be careful. c removes needed dependencies, too. (NOTE: Maybe n is not needed here.)
            forceful )
                pacman -Qq | fzf --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rdd && accomplished ;;  ## Be careful. It forcefully removes a package required by another package, without removing the dependent package.
            yay )
                yay -Qem | fzf --preview 'yay -Si {1}' | xargs -ro yay -Rns && accomplished ;;  ## also -Qqem and -Qqm
        esac ;;

    search )
        search_items=( 'search: normal' 'search: detailed summary' 'search: in local repository' )
        search_item="$(pipe_to_fzf "${search_items[@]}")" && wrap_fzf_choice "$search_item" || exit 37

        case "$search_item" in
            'search: normal' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro pacman -Ss && accomplished ;;
            'search: detailed summary' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro pacman -Si && accomplished ;;
            'search: in local repository' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro pacman -Qs && accomplished ;;
        esac ;;

    packages )
        packages_items=( 'count' 'names' 'AUR packages' 'pacman tools' 'system stats (using yay)' )
        packages_item="$(pipe_to_fzf "${packages_items[@]}")" && wrap_fzf_choice "$packages_item" || exit 37

        case "$packages_item" in
            count )
                pkg_count="$(wc -l < <(pacman -Q))"
                printf '%s\n' "$pkg_count" && accomplished ;;
            names )
                pacman -Q | fzf --preview 'pacman -Si {1}' && accomplished ;;
            'AUR packages' )
                pacman -Qem | fzf --preview 'yay -Si {1}' && accomplished ;;  ## also -Qqem and -Qqm
            'pacman tools' )
                pacman -Ql pacman | \grep -E 'bin/.+' | fzf && accomplished ;;  ## Also: pacman -Ql pacman pacman-contrib | \grep -E 'bin/.+'
            'system stats (using yay)' )
                yay -Ps && accomplished ;;
        esac ;;

    'clear junks and clipboard' )
        action_now 'clearing clipboard'
        greenclip_clear

        action_now "removing ~/.cache content (size: $(get_dir_size ~/.cache/)):"
        \rm -rf -- ~/.cache/*
        ## a safer version of:
        ##   rm -rf ~/.cache

        action_now 'removing files:'
        files=(
            ~/.awesome_stderr
            ~/.awesome_stdout
            ~/.python_history
            ~/.recently-used
            ~/.viminfo
            ~/.wget-hsts
        )
        for file in "${files[@]}"; do
            printf '  %s\n' "$(to_tilda "$file")"
            \rm -f "$file"
        done

        action_now "removing pacman cache and database (size: $(get_dir_size /var/cache/pacman/pkg/))"
        ## cc will clean all the files (which is not a good idea)
        sudo pacman -Sc --noconfirm

        action_now 'checking for orphans'
        readarray -t orphans < <(pacman -Qtdq)
        if [ "$orphans" ]; then
            printf '%s\n' "${orphans[@]}" | sort | column
            remove_orphans="$(get_input "remove "${#orphans[@]}" orphans?")" && printf '\n'
            case "$remove_orphans" in
                y )
                    sudo pacman -Rns "${orphans[@]}" --noconfirm ;;
                * )
                    yellow '  removing orphans skipped' ;;
            esac
        else
            printf '  no orphans\n'
        fi

        printf '\n'
        printf '%s shutdown\n' "$(blue 's')"
        printf '%s reboot\n'   "$(blue 'r')"
        reboot_prompt="$(get_input '>')" && printf '\n'
        case "$reboot_prompt" in
            s ) shutdown -h now ;;
            r ) shutdown -r now ;;
        esac
        accomplished ;;

    update )
        update_items=( 'pacman' 'yay' 'yay + torsocks' 'sync repos' )
        update_item="$(pipe_to_fzf "${update_items[@]}")" && wrap_fzf_choice "$update_item" || exit 37

        case "$update_item" in
            pacman )
                sudo pacman -Syu && \
                accomplished ;;
            yay )
                yay --answerdiff None --answerclean All --removemake -Syua && \
                accomplished ;;
            'yay + torsocks' )
                torsocks yay --answerdiff None --answerclean All --removemake -Syua && \
                accomplished ;;
            'sync repos' )
                sudo pacman -Sy && \
                accomplished ;;
        esac ;;

    help )
        application_help ;;

esac
