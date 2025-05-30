#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-audio.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-audio.sh
##    https://davoudarsalani.ir

## can also use pactl

## vol
def_sink_name="$(pacmd list-sinks | \grep -iA 1 '\*' | \grep -i 'name:' | \grep -ioP '(?<=<).*?(?=>)')"
def_sink_index="$(pacmd list-sinks | \grep -i '\*' | awk '{print $NF}')"
vol_level="$(pacmd list-sinks | \grep -iA 6 "$def_sink_name" | \grep -i 'volume: front' | awk '{print $5}' | tr -d \%)"
vol_state="$(pacmd list-sinks | \grep -iA 3 "$def_sink_name" | \grep -i 'state:' | awk '{print $NF}')"  ## RUNNING/SUSPENDED/IDLE
if \grep -q '^bluez_sink' <<< "$def_source_name"; then
    ## when bluetooth headset is connected
    vol_mute_status="$(pacmd list-sinks | \grep -i 'muted' | awk '{print $NF}' | sed '2q;d')"
else
    vol_mute_status="$(pacmd list-sinks | \grep -i 'muted' | awk '{print $NF}' | sed '1q;d')"
fi

## mic
def_source_name="$(pacmd list-sources | \grep -iA 1 '\*' | \grep -i 'name:' | \grep -ioP '(?<=<).*?(?=>)')"
def_source_index="$(pacmd list-sources | \grep -i '\*' | awk '{print $NF}')"
mic_level="$(pacmd list-sources | \grep -iA 6 "$def_source_name" | \grep -i 'volume: front' | awk '{print $5}' | tr -d \%)"
mic_state="$(pacmd list-sources | \grep -iA 3 "$def_source_name" | \grep -i 'state:' | awk '{print $NF}')"  ## RUNNING/SUSPENDED/IDLE
mic_mute_status="$(pacmd list-sources | \grep -A 10 "$def_source_name" | \grep -i 'muted' | awk '{print $NF }')"

## mon
mons="$(pacmd list-sources | \grep -iB 1 '\.monitor' | \grep -ioP '(?<=<).*?(?=>)')"
if \grep -q '^bluez_sink' <<< "$mons"; then
    ## when bluetooth headset is connected
    def_source_mon_name="$(printf '%s\n' "$mons" | \grep '^bluez_sink')"
else
    def_source_mon_name="$(printf '%s\n' "$mons" | \grep -v '^bluez_sink')"
fi
def_source_mon_index="$(pacmd list-sources | \grep -iB 1 "$def_source_mon_name" | \grep -i 'index' | awk '{print $NF}')"
mon_level="$(pacmd list-sources | \grep -iA 6 "$def_source_mon_name" | \grep -i 'volume: front' | awk '{print $5}' | tr -d \%)"
mon_state="$(pacmd list-sources | \grep -iA 3 "$def_source_mon_name" | \grep -i 'state:' | awk '{print $NF}')"  ## RUNNING/SUSPENDED/IDLE
mon_mute_status="$(pacmd list-sources | \grep -iA 10 "$def_source_mon_name" | \grep -i 'muted' | awk '{print $NF}')"

active_sink_port="$(pacmd list-sinks     | \grep -iA 65 '*' | \grep -i 'active port' | \grep -ioP '(?<=<).*?(?=>)')"
active_source_port="$(pacmd list-sources | \grep -iA 65 '*' | \grep -i 'active port' | \grep -ioP '(?<=<).*?(?=>)')"
