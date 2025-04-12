#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/awesome-widgets.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/awesome-widgets.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

declare -i threshhold=70

case "$1" in
    wifi )
        case "$2" in
            turn_on )
                nmcli radio wifi on && \
                msgn "<span color=\"${gruvbox_orange}\">wifi</span> turned on" || \
                msgn "<span color=\"${gruvbox_orange}\">wifi</span> turn on failed" ;;
            turn_off )
                nmcli radio wifi off && \
                msgn "<span color=\"${gruvbox_orange}\">wifi</span> turned off" || \
                msgn "<span color=\"${gruvbox_orange}\">wifi</span> turn off failed" ;;
        esac ;;

    openvpn )
        original=/etc/resolv.conf
        backup=/etc/resolv.conf--backup
        head=/etc/resolv.conf.head

        function start_openvpn {
            ## --verb 0: No output except fatal errors.
            sudo openvpn \
                 --config         /etc/openvpn/client/RRR.ovpn \
                 --auth-user-pass ~/main/configs/cfg-openvpn/00-credentials-RRR-openvpn \
                 --askpass        ~/main/configs/cfg-openvpn/00-credentials-RRR-openvpn-private-key-password \
                 --log            /tmp/RRR-openvpn-$(date '+%Y-%m-%d-%H-%M-%S').log \
                 --daemon \
                 --verb 0 || return 1

            ## wait briefly to let VPN establish
            sleep 3

            ## create backup if not exists
            if [ ! -f "$backup" ]; then
                sudo cp "$original" "$backup" || return 1
            fi

            sudo cp "$head" "$original" || return 1
        }

        function stop_openvpn {
            ## kill forcefully
            sudo pkill -9 openvpn || return 1

            if [ -f "$backup" ]; then
                sudo cp "$backup" "$original" || return 1
            fi
        }

        function check_status {
            if_on="$(pgrep 'openvpn')"
        }
        check_status

        case "$2" in
            start )
                if [ "$if_on" ]; then
                    message_suffix='already on'
                else
                    start_openvpn && message_suffix='started' || message_suffix='start failed'
                fi ;;
            stop )
                stop_openvpn && message_suffix='stopped' || message_suffix='stop failed' ;;
            restart )
                message_suffix='restart failed'
                stop_openvpn && start_openvpn && message_suffix='restarted' ;;
        esac

        msgn "<span color=\"${gruvbox_orange}\">openvpn</span> ${message_suffix}" ;;

    ## -------------------------------

    clock )
        case "$2" in
            date_jdate )
                message="$(printf '%s\n%s\n%s\n%s' \
                        "$(get_datetime 'jweekday')" \
                        "$(date  +%Y-%m-%d)" \
                        "$(jdate +%Y-%m-%d)" \
                        "$(jdate +%H:%M:%S)"
                        )"
                msgn "$message" ;;
        esac

        hm="$(date '+%I:%M')"
        set_widget 'clock' 'markup' "$hm" ;;

    audio )
        function update_variables {
            source ~/main/scripts/gb-audio.sh
        }

        update_variables

        function mute_vol {
            pactl set-sink-mute "$def_sink_index" 1  ## OR pactl set-sink-mute "$def_sink_index" true  <--,
        }                                            ##                                                   |
                                                     ##                                                   |
        function unmute_vol {                        ##                                                   |
            pactl set-sink-mute "$def_sink_index" 0  ## OR pactl set-sink-mute "$def_sink_index" false <--'-- pactl set-sink-mute "$def_sink_index" toggle
        }


        function mute_mic {
            pactl set-source-mute "$def_source_index" 1
        }

        function unmute_mic {
            pactl set-source-mute "$def_source_index" 0
        }

        # function mic_0 {
        #     pactl set-source-volume "$def_source_index" 0%
        # }

        # function mic_25 {
        #     pactl set-source-volume "$def_source_index" 25%
        # }

        function mute_mon {
            pactl set-source-mute "$def_source_mon_index" 1
        }

        function unmute_mon {
            pactl set-source-mute "$def_source_mon_index" 0
        }

        # function mon_0 {
        #     pactl set-source-volume "$def_source_mon_index" 0%
        # }

        # function mon_100 {
        #     pactl set-source-volume "$def_source_mon_index" 100%
        # }

        function connecttoheadset {
            source ~/main/scripts/gb-fir-blu-batt.sh
            local output text

            msgn "connecting to headset <span color=\"${gruvbox_orange}\">${headset_mac}</span>"

            output="$(bluetoothctl connect "$headset_mac")"
            if ! \grep -qi 'failed to connect' <<< "$output"; then
                msgn "connected to <span color=\"${gruvbox_orange}\">${headset_mac}</span>"
            else
                text="$(printf "connecting to <span color=\"%s\">%s</span>\n%s\n" "$gruvbox_orange" "$headset_mac" "$output")"
                 msgc 'ERROR' "$text" ~/main/configs/themes/alert-w.png
            fi
        }

        case "$2" in
            vol_30 )
                pactl set-sink-volume "$def_sink_index" 30% ;;

            toggle_vol )
                if [ "$vol_mute_status" == 'yes' ]; then
                    unmute_vol
                else
                    mute_vol
                fi ;;
            vol_up )
                pactl set-sink-volume "$def_sink_index" +5% ;;
            vol_down )
                pactl set-sink-volume "$def_sink_index" -5% ;;
            # vol_100 )
            #     pactl set-sink-volume "$def_sink_index" 100% ;;
            # vol_0 )
            #     pactl set-sink-volume "$def_sink_index" 0% ;;

            toggle_mic )
                if [ "$mic_mute_status" == 'yes' ]; then
                    unmute_mic
                else
                    mute_mic
                fi ;;
            mic_up )
                pactl set-source-volume "$def_source_index" +5% ;;
            mic_down )
                pactl set-source-volume "$def_source_index" -5% ;;
            mic_100 )
                pactl set-source-volume "$def_source_index" 100% ;;
            mic_0 )
                pactl set-source-volume "$def_source_index" 0% ;;

            toggle_mon )
                if [ "$mon_mute_status" == 'yes' ]; then
                    unmute_mon
                else
                    mute_mon
                fi ;;
            mon_up )
                pactl set-source-volume "$def_source_mon_index" +5% ;;
            mon_down )
                pactl set-source-volume "$def_source_mon_index" -5% ;;
            mon_100 )
                pactl set-source-volume "$def_source_mon_index" 100% ;;
            mon_0 )
                pactl set-source-volume "$def_source_mon_index" 0% ;;

            connect_to_headset )
                connecttoheadset ;;
            full_info )
text="$(printf '%s\n' \
"<span color=\"${gruvbox_orange}\">Vol</span>
name:   ${def_sink_name}
index:  ${def_sink_index}
level:  ${vol_level}
state:  ${vol_state}
mute:   ${vol_mute_status}

<span color=\"${gruvbox_orange}\">Mic</span>
name:   ${def_source_name}
index:  ${def_source_index}
level:  ${mic_level}
state:  ${mic_state}
mute:   ${mic_mute_status}

<span color=\"${gruvbox_orange}\">Mon</span>
name:   ${def_source_mon_name}
index:  ${def_source_mon_index}
level:  ${mon_level}
state:  ${mon_state}
mute:   ${mon_mute_status}

<span color=\"${gruvbox_orange}\">Active ports</span>
sink:   ${active_sink_port}
source: ${active_source_port}")"
msgn "$text" ;;
            esac

        update_variables

        [ "$vol_mute_status" == 'yes' ] && vol_on_off="<span color=\"${gruvbox_red}\">:OF</span>"
        (( vol_level > 0 )) || vol_level="<span color=\"${gruvbox_red}\">${vol_level}</span>"

        ## mic is on
        if [ "$mic_mute_status" == 'no' ]; then
          mic_info="  MIC:<span color=\"${gruvbox_red}\">${mic_level}:ON</span>"

        ## mic is off
        else
          if (( mic_level > 0 )); then
              mic_info="  MIC:<span color=\"${gruvbox_red}\">${mic_level}:OF</span>"
          else
              mic_info=''
          fi
        fi

        ## mon is on
        if [ "$mon_mute_status" == 'no' ]; then
          mon_info="  MON:<span color=\"${gruvbox_red}\">${mon_level}:ON</span>"

        ## mon is off
        else
          if (( mon_level > 0 )); then
              mon_info="  MON:<span color=\"${gruvbox_red}\">${mon_level}:OF</span>"
          else
              mon_info=''
          fi
        fi


        # states_initials="${vol_state::1}${mic_state::1}${mon_state::1}"  ## RSI
        # indeces="${def_sink_index}${def_source_index}${def_source_mon_index}"  ## 010
        #
        # headset_regex='bluez_sink*'
        # [[ "$def_sink_name" =~ $headset_regex ]] && headset_connectivity=' HE'
        ## previously: [ "$(printf '%s\n' "$def_sink_name" | \grep '^bluez_sink')" ] && headset_connectivity=' HE'
        #
        # xtra_info=" ${states_initials} ${indeces}${headset_connectivity}"

        set_widget 'audio' 'markup' "${vol_level}${vol_on_off}${mic_info}${mon_info}${xtra_info}" ;;

    memory_cpu )
        source ~/main/scripts/gb-calculation.sh

        case "$2" in
            intensives )
                top_memory="$(ps axch -o cmd:15,%mem --sort=-%mem | head -n 10)"  ## <--,-- 15 makes it only 15 characters long
                top_cpu="$(ps axch -o cmd:15,%cpu --sort=-%cpu | head -n 10)"     ## <--'
                message_text="$(printf "<span color=\"%s\">Memory</span>\n%s\n\n<span color=\"%s\">CPU</span>\n%s\n" "$gruvbox_orange" "$top_memory" "$gruvbox_orange" "$top_cpu")"
                msgn "$message_text" ;;
            usage )
                ## NOTE JUMP_3 memory should be calculated at the end becuase IFS=$ in memory section interferes with the calculations in cpu and cpu temperature

                ## cpu (https://www.idnt.net/en-US/kb/941772)
                ## get last usage
                cpu_last_file=~/main/scripts/.last/cpu
                cpu_sum_last_file=~/main/scripts/.last/cpu_sum
                cpu_temp_last_file=~/main/scripts/.last/cpu_temp
                read -a cpu_last < "$cpu_last_file" || cpu_last=( cpu 0 0 0 0 0 0 0 0 0 0 )  ## JUMP_2
                cpu_sum_last="$(< "$cpu_sum_last_file")" || cpu_sum_last=0  ## NOTE do NOT add 2>/dev/null
                cpu_temp_last="$(< "$cpu_temp_last_file")" || cpu_temp_last=0  ## NOTE do NOT add 2>/dev/null

                ## get new usage
                read -a cpu_now < /proc/stat               ## get the first line with aggregate of all cpus
                cpu_sum="${cpu_now[@]:1}"                  ## get all columns but skip the first (which is the 'cpu' string)
                ## ^^ cpu_sum is a str
                (( cpu_sum="${cpu_sum// /+}" ))            ## replace the column seperator (space) with +
                (( cpu_delta="cpu_sum - cpu_sum_last" ))   ## get the delta between two reads
                (( cpu_idle="cpu_now[4] - cpu_last[4]" ))  ## get the idle time delta
                (( cpu_used="cpu_delta - cpu_idle" ))      ## calc time spent working
                cpu_perc="$(float_pad "100*${cpu_used}/${cpu_delta}" 1 1)"
                ## save these as last to compare in our next read
                printf '%s ' "${cpu_now[@]}" > "$cpu_last_file"  ## NOTE no \n
                printf '\n' >> "$cpu_last_file"  ## NOTE JUMP_2 have to append new line (because none was appended in the previous line) otherwise it will exit non-zero when creating cpu_last and therefore activating pipe
                printf '%s\n' "$cpu_sum" > "$cpu_sum_last_file"

                cpu_geater="$(compare_floats "$cpu_perc" ">" "$threshhold")"
                [ "$cpu_geater" == 'true' ] && cpu_perc="<span color=\"${gruvbox_red}\">${cpu_perc}</span>"

                ## cpu temperature
                cpu_temp="$(sensors | \grep 'Package' | cut -d '+' -f 2 |  cut -d '.' -f 1)"
                cpu_temp_greater="$(compare_floats "$cpu_temp" '>' "$threshhold")"
                [ "$cpu_temp_greater" == 'true' ] && cpu_temp="<span color=\"${gruvbox_red}\">${cpu_temp}</span>"

                ## cpu governor
                readarray -t cpu_governor < <(for file in /sys/devices/system/cpu/cpu{0..3}/cpufreq/scaling_governor; {
                    [ -f "$file" ] && [ -r "$file" ] || continue
                    cat "$file"
                } | sort --unique)
                [ "$(printf '%s\n' "${cpu_governor[@]}" | \grep -i 'powersave')" ] || cpu_gov=" <span color=\"${gruvbox_red}\">${cpu_governor[@]^^}</span>"

                ## cpu governors (https://wiki.archlinux.org/title/CPU_frequency_scaling):
                ## performance   Run the CPU at the maximum frequency.
                ## powersave     Run the CPU at the minimum frequency.
                ## userspace     Run the CPU at user specified frequencies.
                ## ondemand      Scales the frequency dynamically according to current load. Jumps to the highest frequency and then possibly back off as the idle time increases.
                ## conservative  Scales the frequency dynamically according to current load. Scales the frequency more gradually than ondemand.
                ## schedutil     Scheduler-driven CPU frequency selection [2], [3].


                ## memory  ## NOTE JUMP_3 memory should be calculated at the end becuase IFS=$ in memory section interferes with the calculations in cpu and cpu temperature
                IFS=$
                mem_info="$(< /proc/meminfo)"
                mem_total="$(printf '%s\n'   "$mem_info" | \grep '^MemTotal'     | awk '{print $2}')"
                mem_free="$(printf '%s\n'    "$mem_info" | \grep '^MemFree'      | awk '{print $2}')"
                mem_buffers="$(printf '%s\n' "$mem_info" | \grep '^Buffers'      | awk '{print $2}')"
                mem_cached="$(printf '%s\n'  "$mem_info" | \grep '^Cached'       | awk '{print $2}')"
                mem_srec="$(printf '%s\n'    "$mem_info" | \grep '^SReclaimable' | awk '{print $2}')"

                (( mem_used="mem_total - mem_free - mem_buffers - mem_cached - mem_srec" ))
                mem_perc="$(float_pad "${mem_used}/${mem_total}*100" 1 1)"

                mem_geater="$(compare_floats "$mem_perc" '>' "$threshhold")"
                [ "$mem_geater" == 'true' ] && mem_perc="<span color=\"${gruvbox_red}\">${mem_perc}</span>"

                set_widget 'memory_cpu' 'markup' "${mem_perc}  ${cpu_perc}  ${cpu_temp}°${cpu_gov}" ;;
        esac ;;

    harddisk )
        source ~/main/scripts/gb-calculation.sh

        case "$2" in
            partitions )
                partitions_text="$(printf "<span color=\"%s\">lsblk</span>\n%s\n\n<span color=\"%s\">mounted drives</span>\n%s\n" "$gruvbox_orange" "$(lsblk_full)" "$gruvbox_orange" "$(mounted_drives 'human_readable')")"
                msgn "$partitions_text" ;;
            usage )
                root_size="$(mounted_drives | \grep '\/$' | awk '{print $3}')"
                root_used="$(mounted_drives | \grep '\/$' | awk '{print $4}')"
                (( root_used > 0 )) && root_used="$(float_pad "${root_used}*100/${root_size}" 1 1)"
                root_geater="$(compare_floats "$root_used" '>' "$threshhold")"
                [ "$root_geater" == 'true' ] && root_used="<span color=\"${gruvbox_red}\">${root_used}</span>"

                home_size="$(mounted_drives | \grep '\/home$' | awk '{print $3}')"
                home_used="$(mounted_drives | \grep '\/home$' | awk '{print $4}')"
                (( home_used > 0 )) && home_used="$(float_pad "${home_used}*100/${home_size}" 1 1)"
                home_greater="$(compare_floats "$home_used" '>' "$threshhold")"

                [ "$home_greater" == 'true' ] && home_used="<span color=\"${gruvbox_red}\">${home_used}</span>"

                swap_size="$(swapon --summary | \grep -i 'partition' | awk '{print $3}')"
                swap_used="$(swapon --summary | \grep -i 'partition' | awk '{print $4}')"
                (( swap_used > 0 )) && swap_used="$(float_pad "${swap_used}*100/${swap_size}" 1 1)"
                swap_geater="$(compare_floats "$swap_used" '>' "$threshhold")"
                [ "$swap_geater" == 'true' ] && swap_used="<span color=\"${gruvbox_red}\">${swap_used}</span>"

                hdd_temp="$(sudo hddtemp /dev/sda --numeric)"

                hdd_temp_geater="$(compare_floats "$hdd_temp" '>' "$threshhold")"
                [ "$hdd_temp_geater" == 'true' ] && hdd_temp="<span color=\"${gruvbox_red}\">${hdd_temp}</span>"

                set_widget 'harddisk' 'markup' "${root_used}  ${home_used}  ${swap_used}  ${hdd_temp}°" ;;
        esac ;;

    # gpu )
    #     active_gpu="$(optimus-manager --status | \grep 'Current GPU mode' | awk '{print $NF}')"
    #     active_gpu="${active_gpu::1}"
    #     [ "$active_gpu" == 'n' ] && active_gpu="<span color=\"${gruvbox_red}\">${active_gpu}</span>"
    #     set_widget 'gpu' 'markup' "$active_gpu" ;;

    processes )
        processes_count="$(wc -l < <(pgrep .))"  ## previously: "$(wc -l < <(ps -aux))"
        set_widget 'processes' 'markup' "$processes_count" ;;

    status )
        ~/main/scripts/status.py ;;

    mbl_umbl )
        get_mountable_umountable
        m_count="${#mountable[@]}";  (( m_count > 0 )) && M="M:${m_count}"
        u_count="${#umountable[@]}"; (( u_count > 0 )) && U="U:${u_count}"
        (( m_count > 0 && u_count > 0 )) && seperator=','
        (( m_count > 0 || u_count > 0 )) && text="${M}${seperator}${U}" || text='MU'

        set_widget 'mbl_umbl' 'markup' "$text" ;;

    firewall )
        function update_variables {
            source ~/main/scripts/gb-fir-blu-batt.sh
        }

        update_variables

        case "$2" in
            turn_on )
                sudo ufw enable  ;;
            turn_off )
                sudo ufw disable ;;
        esac

        update_variables

        case "$firewall_status" in
            active )
                set_widget 'firewall' 'markup' 'FI' ;;
            * )
                set_widget 'firewall' 'markup' 'FI:OF' ;;
        esac ;;

    bluetooth )
        function update_variables {
            source ~/main/scripts/gb-fir-blu-batt.sh
        }

        update_variables

        case "$2" in
            turn_on )
                sudo rfkill unblock bluetooth ;;
            turn_off )
                sudo rfkill block bluetooth   ;;
        esac

        update_variables

        case "$bluetooth_status" in
            yes )
                set_widget 'bluetooth' 'markup' 'BL' ;;
            * )
                set_widget 'bluetooth' 'markup' 'BL:ON' ;;
        esac ;;

    ymail )
        ~/main/scripts/e-mail.py 'ymail' ;;

    gmail )
        sleep 5  ## only to prevent probable collision with ymail
        ~/main/scripts/e-mail.py 'gmail' ;;

    clipboard )
        function check_status {
            if_on="$(pgrep 'greenclip')"
        }
        check_status

        case "$2" in
            start )
                if [ "$if_on" ]; then
                    msgn "<span color=\"${gruvbox_orange}\">greenclip</span> already on"
                else
                    greenclip daemon &
                    msgn "<span color=\"${gruvbox_orange}\">greenclip</span> started"
                fi ;;
            stop )
                pkill greenclip
                msgn "<span color=\"${gruvbox_orange}\">greenclip</span> stopped" ;;
        esac

        [ "$if_on" ] && clipboard_text='CL' || clipboard_text="CL:OF"
        set_widget 'clipboard' 'markup' "$clipboard_text" ;;

    established )
        ## we can add sudo in this case to get instances other than the user-related ones:
        estab="$(sudo lsof -i -P -n | \grep 'ESTABLISHED' | awk '{print $1}' | sort --unique)"  ## -i looks for listing ports, -P inhibits the conversion of port numbers to port names for network files, -n does not use DNS name (https://www.cyberciti.biz/faq/how-to-check-open-ports-in-linux-using-the-cli/)
        estab_count="$(wc -l < <(printf '%s\n' "${estab:?'NONE'}"))"  ## JUMP_1 --,--> expansion structure from https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
                                                                      ##          '--> throws non-skippable error when estab nat available

        (( estab_count > 0 )) && estab_text="ES:${estab_count}" || estab_text='ES'
        set_widget 'established' 'markup' "$estab_text"

        case "$2" in
            message )
                (( estab_count > 0 )) && message_text="$(printf "<span color=\"%s\">Established</span>\n%s\n" "$gruvbox_orange" "$estab")" || message_text='No established connections'
                msgn "$message_text" ;;
        esac ;;

    open_ports )
        ## https://www.cyberciti.biz/faq/how-to-check-open-ports-in-linux-using-the-cli/
        ## -i looks for listing ports
        ## -P inhibits the conversion of port numbers to port names for network files
        ## -n does not use DNS name
        ##
        ## 127.0.0.1:8001 is bestoon project
        open_ports="$(sudo lsof -i -P -n | \grep 'LISTEN' | \grep -v -E '127.0.0.1:8001|mysql|redis|code')"
        open_ports_count="$(wc -l < <(printf '%s\n' "${open_ports:?'NONE'}"))"  ## JUMP_1 --,--> expansion structure from https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
                                                                                ##          '--> throws non-skippable error when open_ports nat available
        (( open_ports_count > 0 )) && open_ports_text="OP:${open_ports_count}" || open_ports_text='OP'
        set_widget 'open_ports' 'markup' "$open_ports_text"

        case "$2" in
            message )
                (( open_ports_count > 0 )) && message_text="$(printf "<span color=\"%s\">Open ports</span>\n%s\n" "$gruvbox_orange" "$open_ports")" || message_text='No open ports'
                msgn "$message_text" ;;
        esac ;;

    tor )
        case "$2" in
            start )
                sudo systemctl start tor && message_suffix='started' || message_suffix='start failed'
                msgn "<span color=\"${gruvbox_orange}\">tor</span> ${message_suffix}" ;;
            stop )
                sudo systemctl stop tor && message_suffix='stopped' || message_suffix='stop failed'
                msgn "<span color=\"${gruvbox_orange}\">tor</span> ${message_suffix}" ;;
            restart )
                sudo systemctl restart tor && message_suffix='restarted' || message_suffix='restart failed'
                msgn "<span color=\"${gruvbox_orange}\">tor</span> ${message_suffix}" ;;
            is-tor )
                ~/main/scripts/is-tor.py 'msg' ;;
        esac

        tor_status="$(pgrep 'tor')"
        [ "$tor_status" ] && tor_status_text='TO:ON' || tor_status_text='TO'
        set_widget 'tor' 'markup' "$tor_status_text" ;;

    git )
        source ~/main/scripts/gb-git.sh

        modified_repos=''

        set_widget 'git' 'markup' "$refresh_icon"

        ## FIXME cant use FZF_DEFAULT_COMMAND and FZF_ALT_C_COMMAND_GIT because they are apparently not accessible to this option
        ## FIXME a bit too slow

        ## synced with path flags for FZF_DEFAULT_COMMAND in /etc/bash.bashrc
        path_flags_1="! -path '*.git/*' ! -path '*.cache/*' ! -path '*.venv*/*' ! -path '*kaddy/*' ! -path '*trash/*' 2>/dev/null"

        ## synced with path flags for FZF_ALT_C_COMMAND_GIT in /etc/bash.bashrc
        path_flags_2="! -path '*.config/*' ! -path '*.vim/*' ! -path '*go/*' ! -path '*trash/*'"

        find_cmd="find ~/main/ -type d $path_flags_1 $path_flags_2 -iname '.git' | sed 's#/\.git##' | sort"

        readarray -t all_repos < <(eval "$find_cmd")

        readarray -t non_public_repos < <(printf '%s\n' "${all_repos[@]/\~/$HOME}" | \grep -v 'public')
        readarray -t public_repos     < <(printf '%s\n' "${all_repos[@]/\~/$HOME}" | \grep    'public')

        ## non-public repos:
        for non_public_repo in "${non_public_repos[@]}"; {
            status_count="$(wc -l < <(git_status "$non_public_repo"))"

            (( status_count > 0 )) && {
                base="${non_public_repo##*/}"
                modified_repos+="${base::2}${status_count},"
            }
        }

        ## public repos:
        regex_status=' ST:'
        regex_commits_ahead=' AH:'
        for public_repo in "${public_repos[@]%/.git}"; {
            base="${public_repo##*/}"

            ## check if repo is ahead of origin
            commits_ahead="$(git_commits_ahead "$public_repo")"
            (( commits_ahead > 0 )) && {
                [[ "$modified_repos" =~ $regex_commits_ahead ]] || pref="$regex_commits_ahead"
                modified_repos+=" ${pref}${base::2}${commits_ahead},"
                unset pref
            }

            ## check if there are changes
            status_count="$(wc -l < <(git_status "$public_repo"))"
            (( status_count > 0 )) && {
                [[ "$modified_repos" =~ $regex_status ]] || pref="$regex_status"
                modified_repos+=" ${pref}${base::2}${status_count},"
                unset pref
            }

        }

        [ "$modified_repos" ] && git_text="GI:${modified_repos%,*}" || git_text="GI"  ## %,* is to remove the trailing , and everything coming after that (only one % mean non-greedy)
        set_widget 'git' 'markup' "$git_text" ;;

    ping )
        ping_failed_file=/tmp/ping_failed
        declare -i tried=1

        if [ -f "$ping_failed_file" ]; then
            ## exceptionally colored refresh_icon
            set_widget 'ping' 'markup' "<span color=\"${gruvbox_red}\">${refresh_icon}</span>"
        fi

        while (( tried <= 5 )); do
            ## -W is timeout (time to wait for a response, in seconds)
            ping 8.8.8.8 -c 1 -W 2 &>/dev/null
            exit_code="$?"

            ## NOTE used [ "$var" -eq 0 ] instead of (( var == 0 )) because
            ##      (( var == 0 )) is stupid (i.e. it returns true even if var does not exist)
            if [ "$exit_code" -eq 0 ]; then
                stts=''
                if [ -f "$ping_failed_file" ]; then
                    # text="$(printf 'Connected back at\n%s\n' "$(jdate '+%Y-%m-%d %H:%M:%S')")"
                    # msgc "$text"
                    rm "$ping_failed_file"
                fi
                break
            else
                stts="<span color=\"${gruvbox_red}\">PI</span>"  ##  ◖◗
                printf '%s\n' "$(get_datetime 'jymdhms')" > "$ping_failed_file"
            fi

            (( tried++ ))

            sleep .1

        done

        set_widget 'ping' 'markup' "$stts" ;;

    audacious )
        source ~/main/scripts/gb-calculation.sh
        source ~/main/scripts/gb-duration.sh

        function update_variables {
            source ~/main/scripts/gb-audacious.sh
        }

        csols_file=~/main/scripts/.last/csols

        update_variables

        if [ "$album" == 'speech' ]; then
            audtool --equalizer-set 0 0 0 0 0 0 0 0 0 0 0
        else
            audtool --equalizer-set -2.10 -10.86 4.00 5.14 2.10 -0.19 -2.10 -2.86 -4.00 -4.00 -4.00
        fi

        case "$2" in
            play_pause )
                audtool --playback-playpause ;;  ## OR audacious -t
            pause )
                [ "$play_status" == 'playing' ] && audtool --playback-pause ;;
            main_window )
                audtool --mainwin-show ;;  ## OR audacious -H OR audacious -m
            resume )
                [ "$album" == 'speech' ] && audtool --playback-seek "$(< "$csols_file")" ;;
            tog_shuff )
                audtool --playlist-shuffle-toggle ;;
            prev )
                audtool --playlist-reverse ;;  ## OR audacious -r
            next )
                audtool --playlist-advance ;;  ## OR audacious -f
            # forward )
            #     forward_length=120
            #     (( remaining_seconds="length_in_seconds - current_position_in_seconds" ))
            #     if (( remaining_seconds < forward_length )); then
            #         audtool --playlist-advance
            #     else
            #         audtool --playback-seek-relative "+${forward_length}"
            #     fi ;;
            -60 )
                audtool --playback-seek-relative -60 ;;
            +60 )
                audtool --playback-seek-relative +60 ;;
            songs )
                IFS=$'\n'
                readarray -t current_songs < <(audtool --playlist-display)

                rofi__title="$1"
                rofi__subtitle="$2"
                selected_song="$(pipe_to_rofi "${current_songs[@]}")" || exit 37

                selected_song_index="$(printf '%s\n' "$selected_song" | awk '{print $1}')"
                audtool --playlist-jump "$selected_song_index" ;;
        esac

        update_variables

        if [ "$play_status" == 'stopped' ]; then
            text=''
            bar_position=0
        else
            ## save currnt song output length seconds (csols) if speech
            regex='^(playing|paused)$'
            [[ "$play_status" =~ $regex ]] && [ "$album" == 'speech' ] && {
                printf '%s\n' "$current_position_in_seconds" > "$csols_file"
                # msgn 'saved csol' "<span color=\"${gruvbox_orange}\">${current_position}</span>"
            }

            [ "$play_status" == 'playing' ] || paused_text='PAUSED '
            preamp_is_zero="$(compare_floats "$preamp" '=' 0)"
            [ "$preamp_is_zero" == 'false' ] && equalizer='EQ '
            [ "$shuffle_status" == 'on' ] && shuffle_text='SH '

            order="${position_in_playlist}/${playlist_length}"  ## 1/5
            [ "$length" ] && timestamp="${current_position}/${length}" || timestamp='0:00/0:00'  ## 2:24/18:54
            (( bar_position > 99 )) && bar_position=1 || bar_position=0.${bar_position}
            left="$(convert_second "$left_in_seconds")"  ## 01:05:16
            left="$(shorten_duration "$left")"  ## 1:05:16

            paused_text="<span color=\"${gruvbox_yellow}\">${paused_text}</span>"
            equalizer="<span color=\"${gruvbox_aqua}\">${equalizer}</span>"
            shuffle_text="<span color=\"${gruvbox_purple}\">${shuffle_text}</span>"
            ##
            timestamp="<span color=\"${gruvbox_blue_d}\">${timestamp}</span>"
            title="<span color=\"${gruvbox_blue_d}\">${title}</span>"
            artist="<span color=\"${gruvbox_blue_d}\">${artist}</span>"

            text="${paused_text}${equalizer}${shuffle_text}${order} ${timestamp} -${left} ${title} ${album} ${artist}"
        fi

        set_widget 'audacious' 'markup' "$text"

        ## set_widget doesn't work properly for audacious_bar
        awesome-client "audacious_bar.value =  ${bar_position}"
        awesome-client "audacious_bar.color = '${gruvbox_blue_d}'"
        ;;
esac
