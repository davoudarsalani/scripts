#!/usr/bin/env bash

## last modified: 1400-09-05 10:51:20 Friday

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

title="${0##*/}"

function if_git {  ## {{{
    [ "$1" ] && {
        if [ "$1" == 's' ]; then
            cd "$HOME"/scripts
        elif [ "$1" == 'l' ]; then
            cd "$HOME"/linux
        # else
        #     red 'Wrong arg' && exit
        fi
    }
    [ ! "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ] && red 'no git' && exit
}
## }}}
if_git "$1"

function if_locked {  ## {{{
    lock_file=.git/index.lock
    [ -f "$lock_file" ] && red 'locked' && exit  ## 
}
## }}}
if_locked

function check_pattern {  ## {{{
    matches="$(find . -mindepth 1 -iname "$pattern")"   ## -maxdepth 1 is not needed here
    [ ! "$matches" ] && red 'no such pattern' && exit
}
## }}}
function if_amend_allowed {  ## {{{
    commits_ahead="$(git branch -v | \grep 'ahead' | \grep -ioP '(?<=\[).*?(?=\])' | awk '{print $2}')"
    ## ^^ previously: git status -s | sed '1q;d' | \grep -i 'ahead' | awk '{print $NF}' | sed 's/[^0-9]//g'
    [ ! "$commits_ahead" ] && red 'amend not allowed' && exit
}
## }}}
function add_to_changes {  ## {{{
    declare -a received=( "$@" )

    local icon="${received[0]}"
    unset 'received[0]'

    for member in "${received[@]}"; {
        changes+=( "${icon}---${member}" )
    }
}
## }}}
function if_changed {  ## {{{
    changes=()  ## NOTE do NOT use declare -a changes since declare makes changes a local variable
    stts="$(git status -s)"
    readarray -t mod   < <(printf '%s\n' "$stts" | \grep '^ M'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${mod[@]}"
    readarray -t del   < <(printf '%s\n' "$stts" | \grep '^ D'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${del[@]}"
    readarray -t ren   < <(printf '%s\n' "$stts" | \grep '^ R'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes 'Ⓡ' "${ren[@]}"
    readarray -t add   < <(printf '%s\n' "$stts" | \grep '^ A'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${add[@]}"
    readarray -t unt   < <(printf '%s\n' "$stts" | \grep '??'            | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${unt[@]}"
    readarray -t sta   < <(printf '%s\n' "$stts" | \grep '^[MDRA] '      | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${sta[@]}"
    readarray -t sta_m < <(printf '%s\n' "$stts" | \grep '^[MDRA][MDRA]' | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${sta_m[@]}"

    [ ! "$changes" ] && green 'sleeping ...' && exit  ## checking if array is empty. no need to [@]
}
## }}}
function pipe_to_fzf_locally {  ## {{{ https://revelry.co/terminal-workflow-fzf/
    local fzf_choice="$(printf '%s\n' "$@" | fzf --nth 2..,.. \
                        --preview-window "$preview_setting" \
                        --preview '(git diff --color=always -- {-1} | sed 1,4d)'
                       )"  ## ^^ ORIG: --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500'
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}
## }}}
function get_branch {  ## {{{ https://revelry.co/terminal-workflow-fzf/
    ## no need to --preview-window "$preview_setting" because it uses the value set in bahrc in FZF_DEFAULT_OPTS
    local fzf_choice="$(printf '%s\n' "$@" | fzf \
                        --preview 'git log --graph --full-history --color --abbrev-commit --date=relative \
                        --pretty="format:%C(blue)%h%Creset %C(bold black)%cr%C(green)%d%Creset %s" $(sed s/^..// <<< {} | awk -F " " "{print $1}") | head -'$LINES \
                        | sed 's/^..//' | awk -F ' ' '{print $1}'  ## ^^ ORIG: --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d " " -f 1) | head -'$LINES | sed 's/^..//'
                       )"
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}
## }}}
function branches_array {  ## {{{
    readarray -t branches_list < <(git branch -a --color=always | \grep -v '/HEAD\s' | sort)  ## branches
    printf '%s\n' "${branches_list[@]}"
}
## }}}

heading "$title"

main_items=( 'status' 'add' 'commit' 'add_commit' 'commit_amend' 'undo' 'unstage' 'log' 'push' 'edit' 'empty_commit' 'remove' 'branch' 'tag' 'revert' 'commits' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    status )  ## {{{
             if_changed
             readarray -t status_items < <(printf '%s\n' "${changes[@]/---/' '}")  ## JUMP_2 for some reason, printf only takes one %s\n no matter how many args are passed to it
             status_item="$(pipe_to_fzf_locally "${status_items[@]}")" && wrap_fzf_choice "$status_item" || exit 37 ;;
             ## }}}
    add )  ## {{{
          if_changed
          readarray -t add_items < <(printf '%s\n' "${changes[@]/---/' '}" 'pattern' 'all')   ## JUMP_2 for some reason, printf only takes one %s\n no matter how many args are passed to it
          add_item="$(pipe_to_fzf_locally "${add_items[@]}")" && wrap_fzf_choice "$add_item" || exit 37

          case "$add_item" in
              pattern )   get_input 'pattern' && pattern="$input"
                          if_locked
                          check_pattern
                          git add "$pattern" && accomplished "$pattern added" ;;
              all )       if_locked
                          git add -A && accomplished 'all added' ;;
              * )         if_locked
                          add_item="${add_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                          git add "$add_item" && accomplished "$add_item added" ;;
          esac ;;
          ## }}}
    commit )  ## {{{
             if_changed
             [ ! "$sta" ] && red 'no staged files' && exit  ## <--,-- "${sta[@]}" throws error:
                                                            ##    |-- line 107: [:  zero: unary operator expected
                                                            ##    '-- so we have to use either "$sta" or "${sta[@]}" 2>/dev/null

             preview_setting='hidden'
             commit_items=( "open $editor" 'write here' )
             commmit_item="$(pipe_to_fzf_locally "${commit_items[@]}")" && wrap_fzf_choice "$commit_item" || exit 37

             case "$commmit_item" in
                 "open $editor" ) if_locked
                                  git commit && accomplished "committed in $editor" ;;
                 'write here' ) get_input 'Message' && message="$input"
                                if_locked
                                git commit -m "$message" && accomplished "committed, message: $message" ;;
             esac ;;
             ## }}}
    add_commit ) ## {{{
                 if_changed
                 readarray -t add_commit_items < <(printf '%s\n' "${changes[@]/---/' '}" 'pattern' 'all' 'all + amend')  ## JUMP_2 for some reason, printf only takes one %s\n no matter how many args are passed to it
                 add_commit_item="$(pipe_to_fzf_locally "${add_commit_items[@]}")" && wrap_fzf_choice "$add_commit_item" || exit 37

                 case "$add_commit_item" in
                     pattern ) get_input 'pattern' && pattern="$input"
                               check_pattern
                               get_input 'message' && message="$input"
                               if_locked
                               git add "$pattern" && git commit -m "${pattern}: $message" && accomplished "$pattern added, message: ${pattern}: $message" ;;
                     all ) get_input 'message' && message="$input"
                           if_locked
                           git add -A && git commit -m "MANY: $message" && accomplished "all added, message: MANY: $message" ;;
                     'all + amend' ) if_amend_allowed
                                     if_locked
                                     git add -A && git commit --amend && accomplished "all added, commit amended in $editor" ;;
                     * ) get_input 'message' && message="$input"
                         if_locked
                         add_commit_item="${add_commit_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                         git add "$add_commit_item" && git commit -m "$add_commit_item: $message" && accomplished "$add_commit_item added, message: $add_commit_item: $message" ;;
                 esac ;;
                 ## }}}
    commit_amend )  ## {{{
                   if_amend_allowed
                   preview_setting='hidden'
                   commit_amend_items=( "open $editor" 'write here' )
                   commit_amend_item="$(pipe_to_fzf_locally "${commit_amend_items[@]}")" && wrap_fzf_choice "$commit_amend_item" || exit 37

                   case "$commit_amend_item" in
                       "open $editor" ) if_locked
                                        git commit --amend && accomplished "commit amended in $editor" ;;
                       'write here' ) get_input 'new message' && new_message="$input"
                                      if_locked
                                      git commit --amend -m "$new_message" && accomplished "commit amended, message: $message" ;;
                   esac ;;
                   ## }}}
    undo )  ## {{{
           if_changed
           readarray -t undo_items < <(printf '%s\n' "${changes[@]/---/' '}" 'pattern' 'all')   ## JUMP_2 for some reason, printf only takes one %s\n no matter how many args are passed to it
           undo_item="$(pipe_to_fzf_locally "${undo_items[@]}")" && wrap_fzf_choice "$undo_item" || exit 37

           case "$undo_item" in
                pattern) get_input 'file/pattern to undo' && pattern="$input"
                         if_locked
                         check_pattern
                         git checkout -- "$pattern" && accomplished "$pattern undid" ;;
                all )    if_locked
                         git checkout -- * && accomplished "all undid" ;;
                * )      if_locked
                         undo_item="${undo_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                         git checkout -- "$undo_item" && accomplished "$undo_item undid" ;;
           esac ;;
           ## }}}
    unstage )  ## {{{
              if_changed
              [ ! "$sta" ] && red 'no staged files' && exit  ## <--,-- "${sta[@]}" throws error:
                                                             ##    |-- line 107: [:  zero: unary operator expected
                                                             ##    '-- so we have to use either "$sta" or "${sta[@]}" 2>/dev/null

              preview_setting='hidden'
              instage_items=( 'all' 'file/pattern' )
              unstage_item="$(pipe_to_fzf_locally "${instage_items[@]}")" && wrap_fzf_choice "$unstage_item" || exit 37

              case "$unstage_item" in
                  all ) if_locked
                        git reset HEAD -- && accomplished 'all unstaged' ;;  ## unstage all staged files
                  'file/pattern' ) get_input 'file/pattern to unstage' && pattern="$input"
                                   if_locked
                                   check_pattern
                                   git reset HEAD -- "$pattern" && accomplished "$pattern unstaged" ;;  ## unstage a specific staged file
              esac ;;
              ## }}}
    log )  ## {{{
          IFS=$'\n'
          if_locked
          preview_setting='hidden'
          readarray -t log_items < <(git log --graph --full-history --all --color --abbrev-commit --date=relative --pretty=format:'%Cblue%h%Creset %C(bold black)%cr%Creset%C(green)%d%Creset %s')
          log_item="$(pipe_to_fzf_locally "${log_items[@]}")" && wrap_fzf_choice "$log_item" || exit 37 ;;
          ## }}}
    push )  ## {{{
           if [ ! "$(git remote -v)" ]; then
               red 'no remote'
           else
               if_locked
               torsocks git push -u origin master && accomplished 'pushed'
           fi ;;
           ## }}}
    edit )  ## {{{
           if_locked
           git config -e && accomplished 'edited' ;;
           ## }}}
    empty_commit )  ## commit with nothing staged {{{

                   preview_setting='hidden'
                   empty_commit_items=( "open $editor" 'write here' )
                   empty_commit_item="$(pipe_to_fzf_locally "${empty_commit_items[@]}")" && wrap_fzf_choice "$empty_commit_item" || exit 37

                   case "$empty_commit_item" in
                       "open $editor" ) if_locked
                                        git commit --allow-empty -n && accomplished 'committed empty' ;;
                       'write here' ) get_input 'message' && message="$input"
                                      if_locked
                                      git commit --allow-empty -n -m "$message" && accomplished "committed empty, message: $message" ;;
                   esac ;;
                   ## }}}
    remove )  ## {{{
             get_input 'file/pattern to remove from git' && pattern="$input"
             if_locked
             git rm -r --cached "$pattern" && accomplished "$pattern removed" ;;
             ## }}}
    branch )  ## {{{
             preview_setting='hidden'
             branch_items=( 'show branches' 'create branch' 'checkout to a branch' 'delete all branches' 'force delete all branches' 'delete a specific branch' 'force delete a specific branch' )
             branch_item="$(pipe_to_fzf_locally "${branch_items[@]}")" && wrap_fzf_choice "$branch_item" || exit 37

             case "$branch_item" in
                 'show branches' ) if_locked
                                   IFS=$'\n'
                                   readarray -t show_branches_items < <(branches_array)
                                   show_branches_item="$(get_branch "${show_branches_items[@]}")" && wrap_fzf_choice "$show_branches_item" && accomplished || exit 37 ;;
                 'create branch' ) get_input 'branch to create' && new_branch="$input"
                                   if_locked
                                   git branch "$new_branch" && accomplished "$new_branch branch created" ;;
                 'checkout to a branch' ) if_locked
                                          IFS=$'\n'
                                          readarray -t cd_to_branch_items < <(branches_array)
                                          cd_to_branch_item="$(get_branch "${cd_to_branch_items[@]}")" && wrap_fzf_choice "$cd_to_branch_item" || exit 37

                                          git checkout "$cd_to_branch_item" && accomplished "$cd_to_branch_item branch checkedout to" ;;
                 'delete all branches' ) if_locked
                                         git branch | \grep -v 'master' | xargs git branch -d && accomplished 'all branches deleted' ;;
                 'force delete all branches' ) if_locked
                                               git branch | \grep -v 'master' | xargs git branch -D && accomplished 'all branches force deleted' ;;
                 'delete a specific branch' ) if_locked
                                              IFS=$'\n'
                                              readarray -t delete_branch_items < <(branches_array)
                                              delete_branch_item="$(get_branch "${delete_branch_items[@]}")" && wrap_fzf_choice "$delete_branch_item" || exit 37

                                              git branch -d "$delete_branch_item" && accomplished "$delete_branch_item branch deleted" ;;
                 'force delete a specific branch' ) if_locked
                                                    IFS=$'\n'
                                                    readarray -t force_delete_branch_items < <(branches_array)
                                                    force_delete_branch_item="$(get_branch "${force_delete_branch_items[@]}")" && wrap_fzf_choice "$force_delete_branch_item" || exit 37

                                                    git branch -D "$force_delete_branch_item" && accomplished "$force_delete_branch_item branch force deleted" ;;
             esac ;;
             ## }}}
    tag )  ## {{{
          preview_setting='hidden'
          tag_items=( 'show tags' 'show a specific tag' 'create tag' 'create tag + message' 'create tag + message for a specific commit' 'delete all tags' 'delete a specific tag')
          tag_item="$(pipe_to_fzf_locally "${tag_items[@]}")" && wrap_fzf_choice "$tag_item" || exit 37

          case "$tag_item" in
              'show tags' ) if_locked
                            git tag && accomplished ;;
              'show a specific tag' ) get_input 'tag to show' && tag="$input"
                                      if_locked
                                      git show "$tag" && accomplished "$tag tag shown" ;;
              'create tag' ) get_input 'tag to create' && new_tag="$input"
                             new_tag="${new_tag// /_}"
                             if_locked
                             git tag "$new_tag" && accomplished "$new_tag tag created" ;;
              'create tag + message' ) get_input 'tag to create' && new_tag="$input"
                                       get_input 'message'       && message="$input"
                                       new_tag="${new_tag// /_}"
                                       if_locked
                                       git tag -a "$new_tag" -m "$message" && accomplished "$new_tag tag created, message: $message" ;;
              'create tag + message for a specific commit' ) get_input 'tag to create' && new_tag="$input"
                                                             get_input 'message'       && message="$input"
                                                             get_input 'commit hash'   && com_hash="$input"
                                                             new_tag="${new_tag// /_}"
                                                             if_locked
                                                             git tag -a "$new_tag" -m "$message" "$com_hash" && accomplished "$new_tag tag created, message: ${message}, for commit: $com_hash" ;;
              'delete all tags' ) if_locked
                                  git tag | xargs git tag -d && accomplished 'all tags deleted' ;;
              'delete a specific tag' ) get_input 'tag to delete' && tag="$input"
                                        if_locked
                                        git tag -d "$tag" && accomplished "$tag tag deleted" ;;
          esac ;;
          ## }}}
    revert )  ## {{{
             IFS=$'\n'
             if_locked
             preview_setting='hidden'
             readarray -t revert_items < <(git log --pretty=oneline --color --abbrev-commit --date=relative --pretty=format:'%Cblue%h%Creset %C(bold black)%cr%Creset%C(green)%d%Creset %s')
             revert_item="$(pipe_to_fzf_locally "${revert_items[@]}")" && wrap_fzf_choice "$revert_item" || exit 37

             revert_item="$(printf '%s\n' "$revert_item" | sed 's/ .*//g')"

             get_single_input "revert to ${revert_item}?" && revert_prompt="$single_input"
             case "$revert_prompt" in
                 y ) git checkout "$revert_item" && accomplished "$revert_item reverted to" ;;
             esac ;;
             ## }}}
    commits )  ## {{{ tell how many times dirs/files have been commited (https://github.com/terminalforlife/BashConfig/blob/master/source/.bash_functions)
               readarray -t all < <(find -mindepth 1 -maxdepth 1 ! -iname '.git' | cut -c 3- | sort)
               for a in "${all[@]}"; {
                   printf '%s %s\n' "$(wc -l < <(git rev-list HEAD "$a"))" "$a"
               } | sort --numeric-sort --reverse | column  ## --numeric-sort is for comparing according to string numerical value
               ;;
               ## }}}
esac

exit

## ╭── git reset --soft HEAD^ : remove the last one commit but keep all the staged and unstaged files as they were.
## ├── git reset --hard HEAD^ : remove the last one commit and undo also all the staged and instaged files before that. In fact it jumps back to the commit before the last one.
## ╰─────► '^' means one commit, '^^' means two commits, and so on
