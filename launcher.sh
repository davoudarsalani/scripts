#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/launcher.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/launcher.sh
##    https://davoudarsalani.ir

case "$1" in
    rofi )
        # ~/.config/rofi/launchers/type-2/style-12.rasi
        rofi \
             -combi-modi ":greenclip print,window,drun" \
             -modi "combi,:greenclip print,window,drun" \
             -show combi \
             -theme ~/.config/rofi/launchers/type-5/style-4.rasi \
             -theme-str 'window { width: 1000; }' \
             -theme-str "window { background-color: ${gruvbox_bg_d}; }" \
             -theme-str 'window { border-radius: 0px; }'
        ;;
    dmenu )
        dmenu_run \
          -i \
          -p 'dmenu' \
          -l "$dmenulines" -fn "$dmenufn" \
          -nb "$dmenunb"   -nf "$dmenunf" \
          -sb "$dmenusb"   -sf "$dmenusf" ;;
esac
