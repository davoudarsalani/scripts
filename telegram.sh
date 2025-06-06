#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/telegram.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/telegram.sh
##    https://davoudarsalani.ir

## Original script by fabianonline (https://github.com/fabianonline/telegram.sh)

## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

VERSION="0.4"
TOKEN=""
CHATS=()
DEBUG=false
DRY_RUN=false

IMAGE_FILE=""
DOCUMENT_FILE=""
PARSE_MODE=""
CODE_MODE=0
CRON_MODE=0
ACTION=""
TITLE=""
DISABLE_WEB_PAGE_PREVIEW=false
DISABLE_NOTIFICATION=false

URL="https://api.telegram.org/bot"
FILE_URL="https://api.telegram.org/file/bot"
CURL_OPTIONS="-s"

HAS_JQ=false
hash jq >/dev/null 2>&1 && HAS_JQ=true

function help {
    version
    echo "Usage: $0 [options] [message]"
    echo
    echo "OPTIONS are:"
    echo "    -t <TOKEN>       Telegram bot token to use. See ENVIRONMENT for more information."
    echo "    -c <CHAT_ID>     Chat to use as recipient. Can be given more than once. See ENVIRONMENT for more information."
    echo "    -f <FILE>        Sends file."
    echo "    -i <FILE>        Sends file as image. This will fail if the file isn't an actual image file."
    echo "    -M               Enables Markdown processing at telegram."
    echo "    -H               Enables HTML processing at telegram."
    echo "    -C               Sends text as monospace code. Useful when piping command outputs into this tool."
    echo "    -r               Like -C, but if the first line starts with '+ ', it is specially formatted."
    echo "    -T <TITLE>       Sets a title for the message. Printed in bold text if -M or -H is used."
    echo "    -l               Fetch known chat_ids."
    echo "    -R               Receive a file sent via telegram."
    echo "    -D               Sets disable_web_page_preview parameter to, well, disable the preview for links to webpages."
    echo "                     Can also be set in config as TELEGRAM_DISABLE_WEB_PAGE_PREVIEW=true (see ENVIRONMENT)"
    echo "                     This feature is only supported for text messages, not when sending files or images (-f, -i)."
    echo "    -N               Diables notifications on clients. Users will receive a notification with no sound."
    echo "                     Can also be set in config as TELEGRAM_DISABLE_NOTIFICATION=true (see ENVIRONMENT)"
    echo "    -m               Outputs the last received message. Format is: <Message ID> <Sender ID> <Chat ID> <Text>"
    echo
    echo "DEBUGGING OPTIONS are:"
    echo "    -v               Display lots of more or less useful information."
    echo "    -j               Pretend you don't have JQ installed."
    echo "    -n               Dry-run - don't send messages, only print them on screen."
    echo
    echo "Message can be '-', in that case STDIN will be used."
    echo
    echo "ENVIRONMENT"
    echo "    TOKEN and CHAT_ID are required. You can set them in four different ways:"
    echo "      1) globally in /etc/telegram.sh.conf"
    echo "      2) user-local in ~/.telegram.sh"
    echo "      3) user-local in ~/.telegram.sh.conf"
    echo "      4) via environment variables telegram_token and telegram_to"
    echo "      5) via options -t and -c"
    echo "    Later methods overwrite earlier settings, so you can easily override global settings."
    echo "    Please be aware that you shuld keep your telegram token secret!"
    echo
    exit
}

function version {
    echo "telegram.sh version $VERSION"
    echo "by Fabian Schlenz"
}

function list_chats {
    log "$URL$TOKEN"
    response=`curl $CURL_OPTIONS $URL$TOKEN/getUpdates`
    log "$response"

    if [ "$HAS_JQ" = true ]; then
        echo "These are the available chats that I can find right now. The ID is the number at the front."
        echo "If there are no chats or the chat you are looking for isn't there, run this command again"
        echo "after sending a message to your bot via telegram."
        echo
        jq -r '.result | .[].message.chat | "\(.id|tostring) - \(.first_name) \(.last_name) (@\(.username))"' 2>/dev/null <<< "$response" || {
            echo "Could not parse reponse from Telegram."
            echo "Response was: $response"
            exit 1
        }
    else
        echo "You don't have jq installed. I'm afraid I can't parse the JSON from telegram without it."
        echo "So I'll have you do it. ;-)"
        echo
        echo "Please look for your chat_id in this output by yourself."
        echo 'Look for something like "chat":{"id":<CHAT_ID> and verify that first_name, last_name and'
        echo "username match your expected chat."
        echo
        echo "If there are no chats listed or the chat you are looking for isn't there, try again after"
        echo "sending a message to your bot via telegram."
        echo
        echo $response
    fi
}

function receive_message {
    if [ "$HAS_JQ" = false ]; then
        echo "You need to have jq installed in order to be able to receive messages."
        exit 1
    fi

    result=`curl $CURL_OPTIONS $URL$TOKEN/getUpdates?allowed_updates=message`
    log "$result"
    if [ "`jq '.result' <<< "$result"`" = "[]" ]; then
        echo "No recent messages."
        exit 1
    fi

    jq -r '.result[-1].message | [(.message_id|tostring), (.from.id|tostring), (.chat.id|tostring), .text] | join(" ")' <<< "$result"
    exit 0
}

function receive_file {
    if [ "$HAS_JQ" = false ]; then
        echo "You need to have jq installed in order to be able to download files."
        exit 1
    fi

    result=`curl $CURL_OPTIONS $URL$TOKEN/getUpdates?allowed_updates=message`
    log "$result"
    # {"ok":true,"result":[
    #   {
    #     "update_id":441727866,
    #     "message":{
    #       "message_id":8339,
    #       "from":{"id":15773,"is_bot":false,"first_name":"Fabian","last_name":"Schlenz","username":"fabianonline","language_code":"de"},
    #       "chat":{"id":15773,"first_name":"Fabian","last_name":"Schlenz","username":"fabianonline","type":"private"},
    #       "date":1526564127,
    #       "document":{"file_name":"desktop.ini","file_id":"BQAav-HkXugI","file_size":282}}}]}
    file_id=`jq -r '.result[-1].message.document.file_id' <<< "$result"`
    log "file_id: $file_id"
    if [ "$file_id" == "null" ]; then
        echo "Last message received apparently didn't contain a file. Aborting."
        exit 1
    fi
    file_name=`jq -r '.result[-1].message.document.file_name' <<< "$result"`
    log "file_name: $file_name"
    result=`curl $CURL_OPTIONS $URL$TOKEN/getFile?file_id=$file_id`
    log $result
    # {"ok":true,"result":{"file_id":"BQAav-HkXugI","file_size":282,"file_path":"documents/file_271.ini"}}
    path=`jq -r '.result.file_path' <<< "$result"`
    log "path: $path"
    if [ "$path" == "null" ]; then
        echo "Could not parse telegram's response to getFile. Aborting."
        exit 1
    fi
    file_name="`date +%s`_$file_name"
    log "file_name: $file_name"
    if [ -e "$file_name" ]; then
        echo "File $file_name already exists. This is unexpected, so I'm quitting now."
        exit 1
    fi
    curl $FILE_URL$TOKEN/$path --output "$file_name"
    echo "File downloaded as $file_name"
}

function log {
    [ "$DEBUG" = true ] && echo "DEBUG: $1"
}

function check_file {
    if [ ! -e "$1" ]; then
        echo "The file $1 does not exist."
        exit 1
    fi

    size=$(stat -c%s "$1")
    if (( size > 52428800 )); then
        echo "File $1 is breaking the file size limit imposed on Telegram bots (currently 50MB)."
        exit 1
    fi
}

function escapeMarkdown {
    res="${1//\*/∗}"
    res="${res//_/＿}"
    res="${res//\`/‵}"
    #res="${res//\//∕}"
    echo "$res"
}

while getopts "t:c:i:f:MHCrhlvjnRmDNT:" opt; do
    case $opt in
        t)
            TOKEN="$OPTARG"
            ;;
        c)
            CHATS+=("$OPTARG")
            ;;
        i)
            IMAGE_FILE="$OPTARG"
            ;;
        f)
            DOCUMENT_FILE="$OPTARG"
            ;;
        M)
            PARSE_MODE="Markdown"
            ;;
        H)
            PARSE_MODE="HTML"
            ;;
        C)
            PARSE_MODE="Markdown"
            CODE_MODE=1
            ;;
        r)
            PARSE_MODE="Markdown"
            CRON_MODE=1
            ;;
        l)
            ACTION="list_chats"
            ;;
        v)
            DEBUG=true
            ;;
        j)
            HAS_JQ=false
            ;;
        n)
            DRY_RUN=true
            ;;
        R)
            ACTION="receive_file"
            ;;
        m)
            ACTION="receive_message"
            ;;
        D)
            DISABLE_WEB_PAGE_PREVIEW=true
            ;;
        N)
            DISABLE_NOTIFICATION=true
            ;;
        T)
            TITLE="$OPTARG"
            ;;
        ?|h)
            help
            ;;
        :)
            echo "Option -$OPTARG needs an argument."
            exit 1
            ;;
        \?)
            echo "Invalid option -$OPTARG"
            exit 1
            ;;
    esac
done

if [ "$CRON_MODE" -eq 1 ] && [ "$CODE_MODE" -eq 1 ]; then
    echo "You can either use -C or -r, but not both."
    exit 1
fi

log "TOKEN is now $TOKEN"
log "CHATS is now ${CHATS[*]}"

[ -z "$TOKEN" ] && TOKEN=$telegram_token
[ ${#CHATS[@]} -eq 0 ] && CHATS=($telegram_to)

log "TOKEN is now $TOKEN"
log "CHATS is now ${CHATS[*]}"

log "Importing config file(s)..."

[ -r /etc/telegram.sh.conf ] && source /etc/telegram.sh.conf
[ -r ~/.telegram.sh ] && source ~/.telegram.sh
[ -r ~/.telegram.sh.conf ] && source ~/.telegram.sh.conf

[ -z "$TOKEN" ] && TOKEN=$telegram_token
[ ${#CHATS[@]} -eq 0 ] && CHATS=($telegram_to)
[ -n "$TELEGRAM_DISABLE_WEB_PAGE_PREVIEW" ] && DISABLE_WEB_PAGE_PREVIEW="$TELEGRAM_DISABLE_WEB_PAGE_PREVIEW"
[ -n "$TELEGRAM_DISABLE_NOTIFICATION" ] && DISABLE_NOTIFICATION="$TELEGRAM_DISABLE_NOTIFICATION"

log "TOKEN is now $TOKEN"
log "CHATS is now ${CHATS[*]}"
log "DISABLE_WEB_PAGE_PREVIEW is now $DISABLE_WEB_PAGE_PREVIEW"
log "DISABLE_NOTIFICATION is now $DISABLE_NOTIFICATION"

if [ -z "$TOKEN" ]; then
    echo "No bot token was given."
    exit 1
fi

if [ ${#CHATS[@]} -eq 0 ] && [ -z "$ACTION" ]; then
    echo "No chat(s) given."
    exit 1
fi

if [ "$ACTION" = "list_chats" ]; then
    list_chats
    exit 0
fi

if [ "$ACTION" = "receive_file" ]; then
    receive_file
    exit 0
fi

if [ "$ACTION" = "receive_message" ]; then
    receive_message
    exit 0
fi

shift $((OPTIND - 1))
TEXT="$1"
log "Text: $TEXT"

[ "$TEXT" = "-" ] && TEXT=$(</dev/stdin)

log "Text: $TEXT"

if [ $CODE_MODE -eq 1 ]; then
    TEXT='```'$'\n'$TEXT$'\n''```'
fi

if [ $CRON_MODE -eq 1 ]; then
    ONLY_COMMANDS=1
    while read line; do
        if [ "${line:0:2}" = "+ " ]; then
            ONLY_COMMANDS=0
        fi
    done <<< "$TEXT"

    if [ "$ONLY_COMMANDS" -eq 1 ]; then
        exit 0
    fi

    TEXT='```'$'\n'$TEXT$'\n''```'

    #FIRST_LINE=1
    #BLOCK_OPEN=0
    #NEW_TEXT=""
    #while read line; do
    #   if [ "${line:0:2}" = "+ " ]; then
    #       if [ "$BLOCK_OPEN" -eq 1 ]; then
    #           NEW_TEXT="$NEW_TEXT"'```'$'\n'
    #           BLOCK_OPEN=0
    #       fi
    #       NEW_TEXT="$NEW_TEXT*`escapeMarkdown "${line:2}"`*"$'\n'
    #   else
    #       if [ "$BLOCK_OPEN" -eq 0 ]; then
    #           NEW_TEXT="$NEW_TEXT"'```'$'\n'
    #           BLOCK_OPEN=1
    #       fi
    #       NEW_TEXT="$NEW_TEXT$line"$'\n'
    #   fi
    #done <<< "$TEXT"
    #[ "$BLOCK_OPEN" -eq 1 ] && NEW_TEXT="$NEW_TEXT"'```'
    #TEXT="$NEW_TEXT"
fi

log "Text: $TEXT"

if [ -n "$TITLE" ]; then
    if [ "$PARSE_MODE" == "HTML" ]; then
        TEXT="<b>$TITLE</b>"$'\n\n'"$TEXT"
    elif [ "$PARSE_MODE" == "Markdown" ]; then
        TEXT="*$TITLE*"$'\n\n'"$TEXT"
    else
        TEXT="$TITLE"$'\n\n'"$TEXT"
    fi
fi

if [ -z "$TEXT" ] && [ -z "$DOCUMENT_FILE" ] && [ -z "$IMAGE_FILE" ]; then
    echo "Neither text nor image or other file given."
    exit 1
fi

if [ -n "$DOCUMENT_FILE" ] && [ -n "$IMAGE_FILE" ]; then
    echo "You can't send a file AND an image at the same time."
    exit 1
fi

[ -n "$PARSE_MODE" ] && CURL_OPTIONS="$CURL_OPTIONS --form-string parse_mode=$PARSE_MODE"
if [ -n "$DOCUMENT_FILE" ]; then
    check_file "$DOCUMENT_FILE"

    CURL_OPTIONS="$CURL_OPTIONS --form document=@\"$DOCUMENT_FILE\""
    CURL_OPTIONS="$CURL_OPTIONS --form caption=<-"
    METHOD="sendDocument"
elif [ -n "$IMAGE_FILE" ]; then
    check_file "$IMAGE_FILE"
    CURL_OPTIONS="$CURL_OPTIONS --form photo=@\"$IMAGE_FILE\""
    CURL_OPTIONS="$CURL_OPTIONS --form caption=<-"
    METHOD="sendPhoto"
else
    CURL_OPTIONS="$CURL_OPTIONS --form text=<-"
    [ "$DISABLE_WEB_PAGE_PREVIEW" = true ] && CURL_OPTIONS="$CURL_OPTIONS --form-string disable_web_page_preview=true"
    METHOD="sendMessage"
fi

[ "$DISABLE_NOTIFICATION" = true ] && CURL_OPTIONS="$CURL_OPTIONS --form-string disable_notification=true"

for id in "${CHATS[@]}"; do
    MY_CURL_OPTIONS="$CURL_OPTIONS --form-string chat_id=$id $URL$TOKEN/$METHOD"
    if [ "$DRY_RUN" = true ]; then
        echo "Executing: curl $MY_CURL_OPTIONS"
        echo "     Text: $TEXT"
        echo
        status=0
        response='{"ok": true}'
    else
        response=`curl $MY_CURL_OPTIONS <<< "$TEXT"`
        status=$?
    fi
    log "Response was: $response"
    if [ $status -ne 0 ]; then
        echo "curl reported an error. Exit code was: $status."
        echo "Response was: $response"
        echo "Quitting."
        exit $status
    fi

    if [ "$HAS_JQ" = true ]; then
        if [ "`jq -r '.ok' <<< "$response"`" != "true" ]; then
            echo "Telegram reported following error:"
            jq -r '"\(.error_code): \(.description)"' <<< "$response"
            echo "Quitting."
            exit 1
        fi
    else
        if [[ "$response" != '{"ok":true'* ]]; then
            echo "Telegram reported an error:"
            echo $response
            echo "Quitting."
            exit 1
        fi
    fi
done
