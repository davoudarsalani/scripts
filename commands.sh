#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/commands.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/commands.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

title="${0##*/}"

function ctc_msg {
    local trimmed

    trimmed="$(printf '%s\n' "$@" | tr -d \<,\&)"
    msgn 'copied to clipboard' "<span color=\"${gruvbox_orange}\">${trimmed}</span>"
}

IFS=$'\n'

heading "$title"

readarray -t main_items < <(sed -n '/^COMMANDS:START$/,//p' "$0" | sed '1d')
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

main_item="${main_item##*---> }"

printf '%s\n' "$main_item" | tr -d '\n' | xclip -selection clipboard
ctc_msg "$main_item" && accomplished

exit

COMMANDS:START
print line 5 [i]   ---> sed '5q;d'
print line 5 [ii]  ---> sed -n '5p'
print line 5 [iii] ---> awk NR==5
print last line ---> sed -e '$!d'
print from line 11 to line 15 (both inclusive) ---> sed -n '11,15p'
print from line 11 to the end of file (inclusive) ---> sed -n '11,$p' file
print line 11 and line 15 ---> sed -n '11p;15p'
remove first line ---> sed '1d'
remove last line ---> sed '$d'
remove lines 1 to 3 ---> sed '1,3d'
print columns 4 and 5 ---> awk '{ print $4 " " $5 }'  ## NOTE do NOT replace " with '
remove columns 1 and 2 ---> awk '{ $1=$2=""; print $0 }'  ## NOTE do NOT replace " with '
print last column ---> awk '{ print $NF }'
remove last column ---> sed -r 's/\s+\S+$//'
print first n characters (X is your number) ---> cut -c 1-X
print last n characters (X is your number) ---> "${VAR:(-X)}"
remove first 6 letters of each line ---> cut -c 6-
remove last 6 letters of each line ---> sed 's/.\{6\}$//'
remove empty lines [i]  ---> sed '/^$/d'
remove empty lines [ii] ---> awk NF
remove one line before a string ---> sed -ni '/STRING/{x;d;};1h;1!{x;p;};${x;p;}'
remove one line after  a string ---> sed -i '/STRING/{N;s/\n.*//;}'
cat file until pattern (inclusive) ---> sed '/PATTERN/q'
print line matching the pattern (the same as grep) ---> sed -n '/PATTERN/p'
add string above the line matching the pattern ---> sed '/PATTERN/i THIS STRING WILL BE INSERTED BEFORE PATTERN'
add string below the line matching the pattern ---> sed '/PATTERN/a THIS STRING WILL BE INSERTED AFTER PATTERN'
replace lines matching the patterns ---> sed '/PATTERN1/,/PATTERN2/c\PATTERN1\nNEWTEXT\nPATTERN2'
replace the line matching the pattern ---> sed '/PATTERN/c THIS STRING WILL REPLACE PATTERN'
insert string before 3rd line ---> sed '3i\STRING'
insert string after 3rd line ---> sed '3a\STRING'
print from pattern to the end of file (inclusive) ---> sed -n '/PATTERN/,$p'
remove from pattern to the end of file (inclusive) ---> sed '/PATTERN/,$d'
remove trailing empty lines from file ---> sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba'
print lines between two PATTERN ---> sed -n '/PATTERN1/,/PATTERN2/p' FILE
remove lines between two PATTERN ---> sed '/PATTERN1/,/PATTERN2/d' FILE

remove prefix       ---> "${VAR#PREFIX}"   ## "${x#*/}"  turns a/b/c/d  to  b/c/d
remove long prefix  ---> "${VAR##PREFIX}"  ## "${x##*/}" turns a/b/c/d  to  d      ## JUMP_1
remove suffix       ---> "${VAR%SUFFIX}"   ## "${x%/*}"  turns a/b/c/d  to  a/b/c  ## JUMP_2
remove long suffix  ---> "${VAR%%SUFFIX}"  ## "${x%%/*}" turns a/b/c/d  to  a

print extension ---> "${VAR##*.}"  ## JUMP_1
remove extension ---> "${VAR%.*}"  ## JUMP_2

replace first match ---> "${VAR/FIRSTMATCH/SUBSTITUTE}"
replace all         ---> "${VAR//FIRSTMATCH/SUBSTITUTE}"
replace suffix      ---> "${VAR/%SUFFIX/SUBSTITUTE}"
replace prefix      ---> "${VAR/#PREFIX/SUBSTITUTE}"

reverse-case first character ---> "${VAR~}"
reverse-case all characters  ---> "${VAR~~}"
reverse order of lines (CAUTION: may cause blank lines to be deleted) [i]  ---> sed '1!G;h;$!d'
reverse order of lines (CAUTION: may cause blank lines to be deleted) [ii] ---> sed -n '1!G;h;$p'
replace all the initial occurences of a string [i]  --> sed 's/^STRING*/SUBSTITUTE/'
replace all the initial occurences of a string [ii] --> sed 's/^\(STRING\)*/SUBSTITUTE/'
remove after the last occurrence of a character [i]   ---> sed 's/\(.*\)CHAR.*/\1/'
remove after the last occurrence of a character [ii]  ---> sed 's/CHAR[^CHAR]*$//'
remove after the last occurrence of a character [iii] ---> "${VAR%CHAR*}"
add string to the end of the line ---> sed 's/$/STRING/'
add word to the nth column in every line ---> awk '$1=$1"-word"'  ## NOTE do NOT replace " with '
replace lowercase with uppercase ---> sed 's/[a-z]/\U&/g'
replace uppercase with lowercase ---> sed 's/[A-Z]/\L&/g'
print number of lines ---> sed -n '$='
set delimiter X and print column 2 [i]  ---> cut -d 'DELIMITER' -f 2          ## (recommended) DELIMITER must be a single character
set delimiter X and print column 2 [ii] ---> awk -F 'DELIMITER' '{print $2}'  ##               DELIMITER can be more than one character
make first letter capital ---> sed 's/.*/\u&/'
sort alphabetically ---> sort
replace the first occurrence ---> sed -e '0,/STRING/ s/STRING/SUBSTITUTE/'
show the line that starts with a string (it is case-sensitive) ---> awk '/^STRING/'
print before a string ---> ??
only print numbers (each in a separate line) [i]  ---> grep -io '[0-9]*'
only print numbers (each in a separate line) [ii] ---> grep -io -P '\d*'
print string between Y and Z [i]  ---> grep -ioP '(?<=Y).*?(?=Z)'
print string between Y and Z [ii] ---> grep -ioP 'Y\K.*?(?=Z)'
print next word after a string [i]  ---> awk '{for(i=1;i<=NF;i++) if ($i=="STRING") print $(i+1)}'  ## NOTE do NOT replace " with '
print next word after a string [ii] ---> grep -oP '(?<=STRING )[^ ]+'
grep and awk (awk is case-sensitive) ---> grep -i <string> = awk '/<string>/'
activate sublime log ---> Show console (Ctrl+`) and type: sublime.log_commands(True)
make awk case-insensitive [i]  ---> awk '{IGNORECASE=1} MYCOMMAND ;'
make awk case-insensitive [ii] ---> awk 'tolower($0) ~ MYCOMMAND'
add string to the second line ---> awk 'NR==1{print; print "STRING"} NR!=1'  ## NOTE do NOT replace " with '
print after the last / ---> "${x##*/}" = basename "$x"
remove/replace n characters before a string ---> sed -e 's/.\{NUMBER\}STRING/SUBSTITUTE/'
keep from nth character until nth character (and repeat) ---> "${VAR:0:9}${VAR:13:8}"
uppercase variable's first letter ---> printf '%s\n' "${VAR^}"
uppercase variable's all letters  ---> printf '%s\n' "${VAR^^}"
lowercase variable's first letter ---> printf '%s\n' "${VAR,}"
lowercase variable's all letters  ---> printf '%s\n' "${VAR,,}"
print 1-2-3-4-5-6-7-8-9-10 ---> seq -s - 10
add column from another file ---> paste -d' ' <FILE1> <FILE2>
calculate using awk ---> function awk_calc { awk -SP "BEGIN {print($@)}" 2>/dev/null ;}; awk_calc '12*34/100'  ## # https://github.com/terminalforlife/BashConfig/blob/master/source/.bash_functions
clears the line ---> printf '\33[A'
print function name ---> function myfunction { printf 'This function is %s\n' "$FUNCNAME" ;} ; myfunction
print lines with whose length are between 10 to 20 ---> grep -x '.\{10,20\}'
generate random number ---> (( var="RANDOM % 1000" ))
sequence [i]   ---> for i in `seq 1 10`; { MYCOMMAND ;}
sequence [ii]  ---> for i in {1..10}   ; { MYCOMMAND ;}
sequence [iii] ---> for i in $(seq 10) ; { MYCOMMAND ;}
mutt pattern ---> printf 'MESSAGEBODY\n' | mutt -s 'SUBJECT' RECEPIENTEMAIL -a FILE
type unicode characters ---> crl + shift + u + HEXADECIMALDIGITS
close terminal without terminating tasks ---> disown -a && exit
system clock ---> timedatectl status
print variable length [i]   ---> printf '%s\n' "${#VAR}"
print variable length [ii]  ---> printf '%s' "$VAR" | wc -c  ## NOTE no \n
print variable length [iii] ---> echo -n "$VAR" | wc -c
arrays ---> ARRAY=()             create an empty array
            declare -a ARRAY     create an empty array (local)
            ARRAY=(1 2 3)        initialize array

            readarray -t content < /proc/version  ## turn all output into an array (-t removes trailing \n)  ## returns Line1 Line2 Line3
            readarray -t result < <(ls -1)        ## turn all output into an array (-t removes trailing \n)  ## returns File1 File2 File3

            read -a content < /proc/version       ## turn first line of output into an array  ## returns Line1 [being an array itself]
            read -a result < <(ls -1)             ## turn first line of output into an array  ## returns File1 [being an array itself]

            "${ARRAY[2]}"        retrieve third element
            "${ARRAY[@]}"        retrieve all elements
            "${ARRAY[@]:x:n}"    retrieve n elements starting at index x
            "${!ARRAY[@]}"       retrieve array indices
            "${#ARRAY[@]}"       array length
            ARRAY[0]=3           overwrite 1st element
            ARRAY+=(4)           append value(s)
            ARRAY=( $(ls) )      save ls output as an array of files (NOTE =( "$(ls)" ) or ="$(ls)" saves output as a string)
            unset 'ARRAY[@]'     empty an array
            unset 'ARRAY[0]'     remove first element of array
            unset 'ARRAY[-1]'    remove last element of array
associative array ---> declare -A vids=(['key one']='value one' ['key two']='value two')
                       printf '%s\n' "${!vids[@]}"         ## keys
                       printf '%s\n' "${vids[@]}"          ## values
                       printf '%s\n' "${vids['key one']}"  ## specific
create readonly variable         [i]  ---> readonly var
create readonly variable (local) [ii] ---> declare -r var
diff the output of two commands ---> diff <(MYCOMMAND1) <(MYCOMMAND2)
print sth on the right in bash (align right) ---> printf '%*s\n' "$COLUMNS" 'STRING'
make read input invisible when entering ---> -s
make read input 1 character long ---> -n 1
make sure read input is a number ---> while [ ! "$number" =~ ^[0-9]+$ ]; do read -p '> Numbers only. Try again: ' number ; printf '\33[A' ; done ; printf '\n'
make sure read input is a letter ---> while [ ! "$letter" =~ ^[a-Z]+$ ]; do read -p '> Letters only. Try again: ' letter ; printf '\33[A' ; done ; printf '\n'
erase everything on the line, regardless of cursor position ---> printf '\33[A' OR echo -en '\e[1K\r' OR echo -en '\e[2K'
print emoji ---> echo -e '\u'CODE  ## what about printf?
clear ---> printf \\e[2J\\e[H\\e[m # = clear
ignore terminal interrupt (CTRL+C, SIGINT) ---> trap '' INT
call a function or do a command on window resize ---> trap 'MYCOMMAND OR MYFUNCTION' SIGWINCH
do something before every command ---> trap 'MYCOMMAND' DEBUG
do something when a shell function or a sourced file finishes executing ---> trap 'MYCOMMAND' RETURN
get terminal columns [i]  ---> printf '%s\n' "$(tput cols)"
get terminal columns [ii] ---> printf '%s\n' "$COLUMNS"
in terminal [i]   ---> !MYCOMMAND       runs the commands as it was last run (with all the flags, etc)
in terminal [ii]  ---> Ctl + u          cut to the beginning
in terminal [iii] ---> Ctl + k          cut to the end
in terminal [iv]  ---> Ctl + y          paste
in terminal [v]   ---> Ctl + x + e      open command temporarily in text editor
in terminal [vi]  ---> Alt + .          paste arguments of previous command
in terminal [vii] ---> Alt + Shift + 3  comment the command and run it
http torsocks ---> http_proxy=socks5://127.0.0.1:9050 torsocks
toggle keyboard layout ---> setxkbmap -layout us,ir -option grp:caps_toggle
show swap files ---> swapon --show
delete duplicate, nonconsecutive and non-empty lines from a file ---> vim -esu NONE '+g/\v^(.+)$\_.{-}^\1$/d' +wq FILE
delete duplicate lines (https://stackoverflow.com/questions/1444406/how-to-delete-duplicate-lines-in-a-file-without-sorting-it-in-unix) ---> sed -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; s/\n//; h; P'
open multiple files in vim tabs ---> vim -p FILE1 FILE2 FILE3
turn off screensaver ---> xset s 0 0 && xset -dpms
expand alias in script: ---> shopt -s expand_aliases (put it at the top of script)
stop pop sound ---> add 'options snd-hda-intel power_save=0 power_save_controller=N' to the end of /etc/modprobe.d/alsa-base.conf
repeated character (https://www.unix.com/shell-programming-and-scripting/235829-how-print-particular-character-n-number-times-line.html) ---> dashed="$(awk -v i=30 'BEGIN {OFS="-"; $i="-"; print}')"  ## NOTE do NOT replace double quote with single quote
chack if variable is a number [i]  ---> regex='^[0-9]+$'; if [[ "$VAR" =~ $regex ]]; then printf 'number\n'; else printf 'not number\n'; fi
chack if variable is a number [ii] ---> if [ "$VAR" -eq "$VAR" ] 2>/dev/null; then printf 'number\n';  else printf 'not number\n'; fi
chack if variable matches pattern ---> regex='*abc*'; [[ "$VAR" == $regex ]] && printf 'match\n'  ## NOTE do not replace [[ with [, and do NOT quote $regex
newest item in clipboard ---> xclip -o
join many mp3 files (NOT tested) ---> ffmpeg -f concat -safe 0 -i <(for f in ./*.mp3; { printf '%s\n' "file '$PWD/$f'" ;} ) -c copy ./output.mp3
to debug bash script ---> set -x; trap read debug
ls /usr/share/xsessions/ returns awesome.desktop
send both stdout and stderr to null ---> &>/dev/null OR >&/dev/null
include stderr as well when piping ---> |& grep something
get service status ---> systemctl --property=Result show tor  ## returns Result=success
reolution of first framebuffer ---> cat /sys/class/graphics/fb0/virtual_size  ## returns 1366,768
dpi ---> xdpyinfo | \grep 'resolution:' | awk '{print $2}'
convert dos to unix using vim ---> :setlocal ff=unix

truncate [i]   ---> > FILE
truncate [ii]  ---> : > FILE
truncate [iii] ---> true > FILE
truncate [iv]  ---> cat /dev/null > FILE
truncate [v]   ---> cp /dev/null FILE
truncate [vi]  ---> truncate -s 0 FILE
truncate [vii] ---> dd if=/dev/null of=FILE

weather [i]   ---> curl -s wttr.in/zahedan?format=1  ## or wget -qO-
weather [ii]  --->   format=1  >> ☀️ +24°C
weather [iii] --->   format=2  >> ☀️ 🌡️e+24°C 🌬️+↓7km/h
weather [iv]  --->   format=3  >> zahedan: ☀️ +24°C
weather [v]   --->   format=4  >> zahedan: ☀️ 🌡️ +24°C 🌬️ ↓7km/h
weather [vi]  --->   format=j1 >> in json format
                      for parsing the json: format=j1 | jq -rM .'current_condition[0]|(.temp_C)'  ## <--,-- will single quote work too?
                                                                                                  ##    |-- (https://www.youtube.com/watch?v=_Xm3HYGW3lg)
                                                                                                  ##    |-- NOTE: no space after .
                                                                                                  ##    |-- -r removes quotes, -M gives monochrome output
                                                                                                  ##    |-- also: (.weatherDesc[0].value)
                                                                                                  ##    \-- to combine: (.temp_C,.humidity)
weather [vii] ---> curl -s wttr.in/zahedan?format=%t+%h+%p >> +10°C 54% 0.0mm

get installation date ---> stat / | grep 'Birth'
get signal names and integers ---> kill -l
check if array is full  ---> [ "${ARRAY[0]}" ] && ...
check if array is empty ---> [ "${ARRAY[0]}" ] || ...
create var using printf ---> printf -v VAR 'STRING'/NUMBER
insert commas into number ---> printf "%'d\n" NUMBER  ## returns 5,364,536  ## NOTE do NOT change quotes
turn seconds (obtained with $(date +%s) or printf '%(%s)T\n') into a date format ---> printf '%(%F %X)T\n' SECONDS  ## returns 1971-09-14 12:59:24 AM
uniq lines [i]  ---> | sort --unique
uniq lines [ii] ---> | sort | uniq
list fonts ---> fc-list -f '%{file}\n'
stage only a hunk of a modified file ---> git add -p FILE

baskreference ---> [[ 'this is a random string' =~ ^this\ is\ (.*)\ st(ri)ng$ ]]
                   printf '%s\n' "${BASH_REMATCH[0]}"  ## returns this is a random string
                   printf '%s\n' "${BASH_REMATCH[1]}"  ## returns a random
                   printf '%s\n' "${BASH_REMATCH[2]}"  ## returns ri

ignore leading whitespaces/tabs when using EOF:
cat <<-'EOF' > FILE
    #!/usr/bin/env bash
    printf 'STRING\n'
EOF

join multiple videos ---> ## https://askubuntu.com/questions/637074/how-to-merge-multiple-more-than-two-videos-on-ubuntu
                          VID_1="PATH_1"; VID_1_TS="${VID_1}.ts"; ffmpeg -i "$VID_1" -c copy -f mpegts "$VID_1_TS" 2>/dev/null
                          VID_2="PATH_2"; VID_2_TS="${VID_2}.ts"; ffmpeg -i "$VID_2" -c copy -f mpegts "$VID_2_TS" 2>/dev/null
                          VID_3="PATH_3"; VID_3_TS="${VID_3}.ts"; ffmpeg -i "$VID_3" -c copy -f mpegts "$VID_3_TS" 2>/dev/null
                          output="PATH_4"; ffmpeg -i "concat:${VID_1_TS}|${VID_2_TS}|${VID_3_TS}" "$output" 2>/dev/null

the way arithmetic operations are used ---> (( VAR="VAR1 - VAR2" ))
                                            (( VAR="array[3] - VAR1" ))
                                            (( VAR="$(COMMAND) / NUMBER" ))
                                            (( VAR="${VAR1// /+}" ))  ## e.g. VAR1='32 1 761', VAR will be 794
                                            (( VAR++ ))
                                            (( VAR+=NUMBER ))

birth                  ---> stat --format=%w FILE/DIR
last access            ---> stat --format=%x FILE/DIR
last status change     ---> stat --format=%z FILE/DIR
last data modification ---> stat --format=%y FILE/DIR

get dir size ---> du -bs DIR
get file size [i]  ---> du -bs FILE
get file size [ii] ---> stat --format=%s FILE
bind keys to commands (\015 means Enter, can also use \n) [i]  ---> bind '"\C-u":"echo command\015"'  ## Ctrl+u <--,-- https://stackoverflow.com/questions/4200800/in-bash-how-do-i-bind-a-function-key-to-a-command
bind keys to commands (\015 means Enter, can also use \n) [ii] ---> bind '"\eu" :"echo command\015"'  ## Alt+u  <--'
