#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/helps.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/helps.sh
##    https://davoudarsalani.ir


source ~/main/scripts/utils-color.sh

function application_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
$(flag '-p|--package=')
$(flag '-u|--unit=')"
exit
}

function ffmpeg_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
embed subtitle         $(flag '-i|--input-file=') $(flag '-f|--subtitle-file=') $(flag '-o|--output=')
burn subtitle (NOTE: increases size) $(flag '-i|--input-file=') $(flag '-f|--subtitle-file=') $(flag '-o|--output=')
burn embedded subtitle (NOTE: increases size) $(flag '-i|--input-file=') $(flag '-d|--subtitle-index=') $(flag '-o|--output=')
sunc audio             $(flag '-i|--input-file=') $(flag '-x|--offset=') (e.g. 1.2 or -0.8) $(flag '-o|--output=')
sync video             $(flag '-i|--input-file=') $(flag '-x|--offset=') (e.g. 1.2 or -0.8) $(flag '-o|--output=')
trim                   $(flag '-i|--input-file=') $(flag '-s|--start=') (e.g. 00:00:09) $(flag '-e|--end=') (e.g. 00:18:34) $(flag '-o|--output=')
convert                $(flag '-i|--input-file=') $(flag '-o|--output=')
remove audio           $(flag '-i|--input-file=') $(flag '-o|--output=')
replace audio          $(flag '-a|--audio-input=') $(flag '-v|--video-input=') $(flag '-o|--output=')
screenshot             $(flag '-i|--input-file=') $(flag '-t|--time=') (e.g. 00:00:09) $(flag '-o|--output=')
extract frames         $(flag '-i|--input-file=') $(flag '-s|--start=') (e.g. 00:00:09) $(flag '-e|--end=') (e.g. 00:18:34)
negate                 $(flag '-i|--input-file=') $(flag '-o|--output=')
reverse                $(flag '-i|--input-file=') $(flag '-o|--output=')
add 0.3 saturation     $(flag '-i|--input-file=') $(flag '-o|--output=')
show streams           $(flag '-i|--input-file=')
audio stream to keep   $(flag '-i|--input-file=') $(flag '-u|--audio-stream=') (e.g. 1) $(flag '-o|--output=')
live camera            $(flag '-c|--camera=') (e.g. /dev/video0)"
exit
}

function git_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
$(flag '-d|--directory=')
$(flag '-p|--pattern=') (e.g. '*.py')
$(flag '-m|--message=')
$(flag '-b|--branch=')
$(flag '-t|--tag=')
$(flag '-c|--commit-hash=')
$(flag '-x|--proxy')
$(flag '-n|--new-name')
$(flag '-f|--file')"  ## ^^ NOTE pattern needs quotes here, but if pattern is entered through get_input in prompt, it won't
exit
}

function kaddyify_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
$(flag '-s|--sync')
$(flag '-f|--diff')
$(flag '-d|--directory=')"
exit
}

function mount_umount_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
udisksctl mount -b  $(flag '-d|--device=') (e.g. /dev/sdc)
udisksctl umount -b $(flag '-d|--device=') (e.g. /dev/sdc)
format usb device   $(flag '-d|--device=') (e.g. /dev/sdc) $(flag '-n|--name=') (e.g. nnnn)"
exit
}

function network_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
ethernet/wifi connection        $(flag '-c|--connection=')
add ip                          $(flag '-i|--ip=') $(flag '-d|--device=')
delete all ips                  $(flag '-d|--device=')
connect to a new wifi network   $(flag '-s|--ssid=') $(flag '-p|--password=')"
exit
}

function rg_help {
clear
printf '%s\n' \
"$(heading "$title") $(yellow "help")
$(flag '-c|--case-sensitive')
$(flag '-d|--directory=')"
exit
}
