#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/application.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/application.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-color.sh
shopt -s globstar  ## is it needed?

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    application_help
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -p )
                package="${package:-"$(get_input 'package name')"}" ;;
            -u )
                unit="${unit:-"$(get_input 'unit name')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,package:,unit:' --options 'hp:u:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -p|--package )
                shift
                package="$1" ;;
            -u|--unit )
                shift
                unit="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

main_items=( 'install' 'remove' 'packages' 'clear cache and clipboard' 'update' 'systemd' 'systemctl' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    install )
        install_items=( 'pacman' 'yay' 'yay + torsocks' 'local' 'download (no install)' 'reinstall all packages' 'lts kernel & header' 'search: normal' 'search: detailed summary' 'search: in local repository' )
        fzf__title=''
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
            local )
                prompt -p
                sudo pacman -U "$package" && accomplished ;;
            'download (no install)' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro sudo pacman -Sw && accomplished ;;
            'reinstall all packages' )
                reinstall_prompt="$(get_single_input 'you sure?')" && printf '\n'
                case "$reinstall_prompt" in
                    y ) sudo pacman -Qnq | pacman -S - && accomplished ;;
                esac ;;
            'lts kernel & header' )
                start_prompt="$(get_single_input 'start?')" && printf '\n'
                case "$start_prompt" in
                    y )
                        action_now 'Installing'
                        sudo pacman -S --needed linux-lts linux-lts-headers
                        printf '\n'
                        update_prompt="$(get_single_input 'update bootloader?')" && printf '\n'
                        case "$update_prompt" in
                            y )
                                action_now 'Updating bootloader'
                                sudo grub-mkconfig -o /boot/grub/grub.cfg && \
                                accomplished 'Please reboot now.\n  You can choose linux-lts in grub menu when booting.\n  You can remove the latest kernel after reboot.' ;;
                        esac ;;
                esac ;;
            'search: normal' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro pacman -Ss && accomplished ;;
            'search: detailed summary' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro pacman -Si && accomplished ;;
            'search: in local repository' )
                pacman -Slq | fzf --preview 'pacman -Si {1}' | xargs -ro pacman -Qs && accomplished ;;
        esac ;;

    remove )
        remove_items=( 'normal' 'with all dependencies' 'forceful' 'yay' 'latest kernel' )
        fzf__title=''
        remove_item="$(pipe_to_fzf "${remove_items[@]}")" && wrap_fzf_choice "$remove_item" || exit 37

        case "$remove_item" in
            normal )
                pacman -Qq | fzf --preview 'pacman -Si {1}' | xargs -ro sudo pacman -Rns && accomplished ;;  ## s removes dependencies not being used by other packages, and n removes package configuration files
            'with all dependencies' )
                pacman -Qq | fzf --preview 'pacman -Si {1}' | xargs -ro sudo pacman -Rnsc && accomplished ;;  ## Be careful. c removes needed dependencies, too. (NOTE: Maybe n is not needed here.)
            forceful )
                pacman -Qq | fzf --preview 'pacman -Si {1}' | xargs -ro sudo pacman -Rdd && accomplished ;;  ## Be careful. It forcefully removes a package required by another package, without removing the dependent package.
            yay )
                yay -Qem | fzf --preview 'yay -Si {1}' | xargs -ro yay -Rns && accomplished ;;  ## also -Qqem and -Qqm
            'remove latest kernel' )
                sudo pacman -R linux && accomplished ;;
        esac ;;

    packages )
        packages_items=( 'count' 'names' 'AUR packages' 'pacman tools' 'system stats (using yay)' )
        fzf__title=''
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

    'clear cache and clipboard' )
        action_now 'clearing clipboard'
        greenclip_clear
        action_now "cache size: $(du -sh /var/cache/pacman/pkg/)"  ## installed apps database dir: var/lib/pacman/
        action_now 'removing cache and database'
        sudo pacman -Sc --noconfirm  ## cc will clean all the files (which is not a good idea)
        action_now 'checking for orphans'
        readarray -t orphans < <(sudo pacman -Qtdq)  ## is sudo needed?
        if [ "$orphans" ]; then
            printf '%s\n' "${orphans[@]}" | sort | column
            remove_orphans="$(get_single_input "remove "${#orphans[@]}" orphans?")" && printf '\n'
            case "$remove_orphans" in
                y )
                    sudo pacman -Rns "${orphans[@]}" --noconfirm ;;
                * )
                    yellow '  removing orphans skipped'
            esac
        else
            printf '  no orphans\n'
        fi
        action_now "removing ~/.cache (size: $(du -sh ~/.cache/ | awk '{print $1}')):"
        rm -rf ~/.cache

        printf '\n'
        printf '%s shutdown\n' "$(blue '1')"
        printf '%s reboot\n'   "$(blue '2')"
        reboot_prompt="$(get_single_input '>')" && printf '\n'
        case "$reboot_prompt" in
            1 ) shutdown -h now ;;
            2 ) shutdown -r now ;;
        esac
        accomplished ;;

    update )
        update_items=( 'pacman' 'yay' 'yay + torsocks' 'sync repos' 'available updates' 'last update' )
        fzf__title=''
        update_item="$(pipe_to_fzf "${update_items[@]}")" && wrap_fzf_choice "$update_item" || exit 37

        case "$update_item" in
            pacman )
                SECONDS=0
                sudo pacman -Syu
                dur="$(convert_second "$SECONDS")"
                accomplished "Total duration: $dur" ;;
            yay )
                start="$(get_datetime 'jseconds')"
                yay --answerdiff None --answerclean All --removemake -Syua
                end="$(get_datetime 'jseconds')"
                dur="$(convert_second "$(( "$end" - "$start" ))")"
                accomplished "Total duration: $dur" ;;
            'yay + torsocks' )
                SECONDS=0
                torsocks yay --answerdiff None --answerclean All --removemake -Syua
                dur="$(convert_second "$SECONDS")"
                accomplished "Total duration: $dur" ;;
            'sync repos' )
                sudo pacman -Sy && accomplished ;;
            'available updates' )
                msgn 'synchronizing repositories ...' '' ~/main/configs/themes/pacman-w.png
                sudo pacman -Sy && \
                ups_count="$(wc -l < <(pacman -Qu | \grep -iv 'IgnorePkg'))"

                sleep 0.1

                ## AUR updates
                aur_ups_count="$(wc -l < <(yay -Qua))"

                sleep 0.1

                if (( ups_count > 0 && aur_ups_count > 0 )); then
                    msgn "available updates: <span color=\"${gruvbox_orange}\">${ups_count}</span> / <span color=\"${gruvbox_orange}\">${aur_ups_count}</span>"
                else
                    msgn "no available updates"
                fi ;;
            'last update' )
                last_update_date="$(grep -E 'pacman -Syu' /var/log/pacman.log | tail -1 | awk '{print $1}' | sed 's/^\[\(.*\)\]$/\1/')"  ## 2021-04-15T11:10:03+0430
                dur="$(relative_date "$last_update_date")"
                printf 'last update: %s (on %s)\n' "$dur" "$last_update_date"
        esac ;;

    systemd )
        systemd_items=( 'systemd-analyze' 'systemd-analyze blame' 'reload systemd' 'reload systemd units' )
        fzf__title=''
        systemd_item="$(pipe_to_fzf "${systemd_items[@]}")" && wrap_fzf_choice "$systemd_item" || exit 37

        case "$systemd_item" in
            'systemd-analyze' )
                systemd-analyze && accomplished ;;
            'systemd-analyze blame' )
                systemd-analyze blame && accomplished ;;
            'reload systemd' )
                systemctl --system daemon-reload && accomplished ;;
            'reload systemd units' )
                systemctl daemon-reload && accomplished ;;  ## a reboot might be required
        esac ;;

    systemctl )
        systemctl_items=( 'status' 'services' 'running units' 'failed units' 'start a unit' 'stop a unit' 'restart a unit' 'unit status' 'reload configuration' 'check if enabled' 'enable' 'disable' 'mask' 'unmask' )
        fzf__title=''
        systemctl_item="$(pipe_to_fzf "${systemctl_items[@]}")" && wrap_fzf_choice "$systemctl_item" || exit 37

        case "$systemctl_item" in
            status )
                systemctl status && accomplished ;;
            services )
                systemctl --type=service && accomplished ;;
            'running units' )
                systemctl list-units && accomplished ;;
            'failed units' )
                systemctl --failed && accomplished ;;
            'start a unit' )
                prompt -u
                sudo systemctl start "$unit" && accomplished ;;
            'stop a unit' )
                prompt -u
                sudo systemctl stop "$unit" && accomplished ;;
            'restart a unit' )
                prompt -u
                sudo systemctl restart "$unit" && accomplished ;;
            'unit status' )
                prompt -u
                systemctl status "$unit" && accomplished ;;
            'reload configuration' )
                prompt -u
                sudo systemctl reload "$unit" && accomplished ;;
            'check if enabled' )
                prompt -u
                systemctl is-enabled "$unit" && accomplished ;;
            enable )
                prompt -u
                sudo systemctl enable "$unit" && accomplished ;;
            disable )
                prompt -u
                sudo systemctl disable "$unit" && accomplished ;;
            mask )
                prompt -u
                sudo systemctl mask "$unit" && accomplished ;;
            unmask )
                prompt -u
                sudo systemctl unmask "$unit" && accomplished ;;
        esac ;;

    help )
        display_help ;;

esac
