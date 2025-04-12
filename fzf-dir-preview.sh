#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/fzf-dir-preview.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/fzf-dir-preview.sh
##    https://davoudarsalani.ir

\ls $LS_FLAGS "${1/\~/$HOME}"  ## NOTE keep \ls escaped
