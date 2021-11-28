#!/usr/bin/env bash

## last modified: 1400-09-07 10:28:59 +0330 Sunday

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color
source "$HOME"/scripts/gb-git

title="${0##*/}"

# dest="${1:-.}"  ## NOTE doing this and using -C "$dest" in front of git instances did not work, not here nor in "$HOME"/scripts/gb-git
[ "$1" ] && {
    if [ "$1" == 's' ]; then
        dest="$HOME"/scripts
    elif [ "$1" == 'l' ]; then
        dest="$HOME"/linux
    else
        red 'only l/s for arg' && exit
    fi
}
[ "$(if_git "$dest")" == 'false' ] && red 'no git' && exit

function if_locked {  ## {{{
    [ -f "${dest:-.}"/.git/index.lock ] && red 'locked' && exit  ## 
}
## }}}
if_locked

function check_pattern {  ## {{{
    matches="$(find -mindepth 1 -iname "$pattern")"   ## -maxdepth 1 is not needed here
    [ ! "$matches" ] && red 'no such pattern' && exit
}
## }}}
function if_amend_allowed {  ## {{{
    (( "$(get_commits_ahead "$dest")" == 0 )) && red 'amend not allowed' && exit
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
    local stts="$(get_status "$dest")"
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
    export dest2="$dest"  ## JUMP_3 we have to do the export because --preview uses subshell making the original dest useless here
    local fzf_choice="$(printf '%s\n' "$@" | fzf --nth 2..,.. \
                        --preview-window "$preview_setting" \
                        --preview '(git -C "${dest2:-.}" diff --unified=0 --color=always -- {-1} | sed 1,4d)'  ## --unified=0 makes git show only the modified lines
                       )"  ## ^^ ORIG: --preview '(git -C "${dest2:-.}" diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500'
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}
## }}}
function get_branch {  ## {{{ https://revelry.co/terminal-workflow-fzf/
    export dest2="$dest"  ## JUMP_3 we have to do the export because --preview uses subshell making the original dest useless here
    ## no need to --preview-window "$preview_setting" because it uses the value set in bahrc in FZF_DEFAULT_OPTS
    local fzf_choice="$(printf '%s\n' "$@" | fzf \
                        --preview 'git -C "${dest2:-.}" log --graph --full-history --color --abbrev-commit --date=relative \
                        --pretty="format:%C(blue)%h%Creset %C(bold black)%cr%C(green)%d%Creset %s" $(sed s/^..// <<< {} | \
                        cut -d " " -f 1)' | sed 's/^..//' | cut -d " " -f 1
                        ## ^^ ORIG: --preview 'git -C "${dest2:-.}" log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d " " -f 1) | head -'$LINES | sed 's/^..//'
                      )"
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}
## }}}
function branches_array {  ## {{{
    declare -a branches_list
    readarray -t branches_list < <(get_branches "$dest")  ## branches
    printf '%s\n' "${branches_list[@]}"
}
## }}}

heading "$title"

main_items=( 'status' 'add' 'commit' 'add_commit' 'commit_amend' 'undo' 'unstage' 'log' 'push' 'edit' 'empty_commit' 'remove' 'branch' 'tag' 'revert' 'commits' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    status )  ## {{{
             if_changed
             pipe_to_fzf_locally "${changes[@]/---/' '}" && accomplished ;;
             ## }}}
    add )  ## {{{
          if_changed
          add_item="$(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all')" && wrap_fzf_choice "$add_item" || exit 37

          case "$add_item" in
              pattern ) get_input 'pattern' && pattern="$input"
                        check_pattern
                        if_locked
                        git -C "${dest:-.}" add "$pattern" && \
                        accomplished "$pattern added" ;;
              all )     if_locked
                        git -C "${dest:-.}" add -A && \
                        accomplished 'all added' ;;
              * )       add_item="${add_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                        if_locked
                        git -C "${dest:-.}" add "$add_item" && \
                        accomplished "$add_item added" ;;
          esac ;;
          ## }}}
    commit )  ## {{{
             if_changed
             [ ! "$sta" ] && red 'no staged files' && exit  ## checking if array is empty. no need to [@]

             preview_setting='hidden'
             commmit_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$commit_item" || exit 37

             case "$commmit_item" in
                 "open $editor" ) if_locked
                                  git -C "${dest:-.}" commit && \
                                  accomplished "committed in $editor" ;;
                 'write here' ) get_input 'Message' && message="$input"
                                if_locked
                                git -C "${dest:-.}" commit -m "$message" && \
                                accomplished "committed, message: $message" ;;
             esac ;;
             ## }}}
    add_commit ) ## {{{
                 if_changed
                 add_commit_item="$(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all' 'all + amend')" && wrap_fzf_choice "$add_commit_item" || exit 37

                 case "$add_commit_item" in
                     pattern ) get_input 'pattern' && pattern="$input"
                               check_pattern
                               get_input 'message' && message="$input"
                               if_locked
                               git -C "${dest:-.}" add "$pattern" && \
                               git -C "${dest:-.}" commit -m "${pattern}: $message" && \
                               accomplished "$pattern added, message: ${pattern}: $message" ;;
                     all ) get_input 'message' && message="$input"
                           if_locked
                           git -C "${dest:-.}" add -A && \
                           git -C "${dest:-.}" commit -m "MANY: $message" && \
                           accomplished "all added, message: MANY: $message" ;;
                     'all + amend' ) if_amend_allowed
                                     if_locked
                                     git -C "${dest:-.}" add -A && \
                                     git -C "${dest:-.}" commit --amend && \
                                     accomplished "all added, commit amended in $editor" ;;
                     * ) add_commit_item="${add_commit_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                         get_input 'message' && message="$input"
                         if_locked
                         git -C "${dest:-.}" add "$add_commit_item" && \
                         git -C "${dest:-.}" commit -m "${add_commit_item}: $message" && \
                         accomplished "$add_commit_item added, message: ${add_commit_item}: $message" ;;
                 esac ;;
                 ## }}}
    commit_amend )  ## {{{
                   if_amend_allowed
                   preview_setting='hidden'
                   commit_amend_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$commit_amend_item" || exit 37

                   case "$commit_amend_item" in
                       "open $editor" ) if_locked
                                        git -C "${dest:-.}" commit --amend && \
                                        accomplished "commit amended in $editor" ;;
                       'write here' ) get_input 'new message' && new_message="$input"
                                      if_locked
                                      git -C "${dest:-.}" commit --amend -m "$new_message" && \
                                      accomplished "commit amended, message: $message" ;;
                   esac ;;
                   ## }}}
    undo )  ## {{{
           if_changed
           undo_item="$(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all')" && wrap_fzf_choice "$undo_item" || exit 37

           case "$undo_item" in
                pattern) get_input 'file/pattern to undo' && pattern="$input"
                         check_pattern
                         if_locked
                         git -C "${dest:-.}" checkout -- "$pattern" && \
                         accomplished "$pattern undid" ;;
                all )    if_locked
                         git -C "${dest:-.}" checkout -- * && \
                         accomplished "all undid" ;;
                * )      undo_item="${undo_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                         if_locked
                         git -C "${dest:-.}" checkout -- "$undo_item" && \
                         accomplished "$undo_item undid" ;;
           esac ;;
           ## }}}
    unstage )  ## {{{
              if_changed
              [ ! "$sta" ] && red 'no staged files' && exit  ## checking if array is empty. no need to [@]

              preview_setting='hidden'
              unstage_item="$(pipe_to_fzf_locally "${instage_items[@]}" 'all' 'file/pattern')" && wrap_fzf_choice "$unstage_item" || exit 37

              case "$unstage_item" in
                  all ) if_locked
                        git -C "${dest:-.}" reset HEAD -- && \
                        accomplished 'all unstaged' ;;  ## unstage all staged files
                  'file/pattern' ) get_input 'file/pattern to unstage' && pattern="$input"
                                   check_pattern
                                   if_locked
                                   git -C "${dest:-.}" reset HEAD -- "$pattern" && \
                                   accomplished "$pattern unstaged" ;;  ## unstage a specific staged file
              esac ;;
              ## }}}
    log )  ## {{{
          IFS=$'\n'
          if_locked
          preview_setting='hidden'
          readarray -t log_items < <(git -C "${dest:-.}" \
                                     log --graph --full-history --all --color --abbrev-commit --date=relative \
                                     --pretty=format:'%Cblue%h%Creset %C(bold black)%cr%Creset%C(green)%d%Creset %s')
          pipe_to_fzf_locally "${log_items[@]}" ;;
          ## }}}
    push )  ## {{{
           if [ "$(if_remote)" ]; then
               if_locked
               torsocks git -C "${dest:-.}" push -u origin master && \
               accomplished 'pushed'
           else
               red 'no remote'
           fi ;;
           ## }}}
    edit )  ## {{{
           if_locked
           git -C "${dest:-.}" config -e && \
           accomplished 'edited' ;;
           ## }}}
    empty_commit )  ## commit with nothing staged {{{
                   preview_setting='hidden'
                   empty_commit_item="$(pipe_to_fzf_locally "${empty_commit_items[@]}" "open $editor" 'write here')" && wrap_fzf_choice "$empty_commit_item" || exit 37

                   case "$empty_commit_item" in
                       "open $editor" ) if_locked
                                        git -C "${dest:-.}" commit --allow-empty -n && \
                                        accomplished 'committed empty' ;;
                       'write here' ) get_input 'message' && message="$input"
                                      if_locked
                                      git -C "${dest:-.}" commit --allow-empty -n -m "$message" && \
                                      accomplished "committed empty, message: $message" ;;
                   esac ;;
                   ## }}}
    remove )  ## {{{
             get_input 'file/pattern to remove from git' && pattern="$input"
             if_locked
             git -C "${dest:-.}" rm -r --cached "$pattern" && \
             accomplished "$pattern removed" ;;
             ## }}}
    branch )  ## {{{
             preview_setting='hidden'
             branch_items=( 'show branches' 'create branch' 'checkout to a branch' 'delete all branches' 'force delete all branches' 'delete a specific branch' 'force delete a specific branch' )
             branch_item="$(pipe_to_fzf_locally "${branch_items[@]}")" && wrap_fzf_choice "$branch_item" || exit 37

             case "$branch_item" in
                 'show branches' ) if_locked
                                   # IFS=$'\n'
                                   get_branch "$(branches_array)" && accomplished ;;
                 'create branch' ) get_input 'branch to create' && new_branch="$input"
                                   if_locked
                                   git -C "${dest:-.}" branch "$new_branch" && \
                                   accomplished "$new_branch branch created" ;;
                 'checkout to a branch' ) if_locked
                                          # IFS=$'\n'
                                          cd_to_branch_item="$(get_branch "$(branches_array)")"
                                          git -C "${dest:-.}" checkout "$cd_to_branch_item" && \
                                          accomplished "$cd_to_branch_item branch checkedout to" ;;
                 'delete all branches' ) if_locked
                                         get_branches_exclude_remote | \grep -v 'master' | \
                                         xargs git -C "${dest:-.}" branch -d && \
                                         accomplished 'all branches deleted' ;;
                 'force delete all branches' ) if_locked
                                               git -C "${dest:-.}" branch | \grep -v 'master' | \
                                               xargs git -C "${dest:-.}" branch -D && \
                                               accomplished 'all branches force deleted' ;;
                 'delete a specific branch' ) if_locked
                                              # IFS=$'\n'
                                              delete_branch_item="$(get_branch "$(branches_array | \grep -v 'master')")" && wrap_fzf_choice "$delete_branch_item" || exit 37
                                              git -C "${dest:-.}" branch -d "$delete_branch_item" && \
                                              accomplished "$delete_branch_item branch deleted" ;;
                 'force delete a specific branch' ) if_locked
                                                    # IFS=$'\n'
                                                    force_delete_branch_item="$(get_branch "$(branches_array | \grep -v 'master')")" && wrap_fzf_choice "$force_delete_branch_item" || exit 37
                                                    git -C "${dest:-.}" branch -D "$force_delete_branch_item" && \
                                                    accomplished "$force_delete_branch_item branch force deleted" ;;
             esac ;;
             ## }}}
    tag )  ## {{{
          preview_setting='hidden'
          tag_items=( 'show tags' 'show a specific tag' 'create tag' 'create tag + message' 'create tag + message for a specific commit' 'delete all tags' 'delete a specific tag')
          tag_item="$(pipe_to_fzf_locally "${tag_items[@]}")" && wrap_fzf_choice "$tag_item" || exit 37

          case "$tag_item" in
              'show tags' ) if_locked
                            git -C "${dest:-.}" tag && \
                            accomplished ;;
              'show a specific tag' ) get_input 'tag to show' && tag="$input"
                                      if_locked
                                      git -C "${dest:-.}" show "$tag" && \
                                      accomplished "$tag tag shown" ;;
              'create tag' ) get_input 'tag to create' && new_tag="$input"
                             new_tag="${new_tag// /_}"
                             if_locked
                             git -C "${dest:-.}" tag "$new_tag" && \
                             accomplished "$new_tag tag created" ;;
              'create tag + message' ) get_input 'tag to create' && new_tag="$input"
                                       get_input 'message'       && message="$input"
                                       new_tag="${new_tag// /_}"
                                       if_locked
                                       git -C "${dest:-.}" tag -a "$new_tag" -m "$message" && \
                                       accomplished "$new_tag tag created, message: $message" ;;
              'create tag + message for a specific commit' ) get_input 'tag to create' && new_tag="$input"
                                                             get_input 'message'       && message="$input"
                                                             get_input 'commit hash'   && com_hash="$input"
                                                             new_tag="${new_tag// /_}"
                                                             if_locked
                                                             git -C "${dest:-.}" tag -a "$new_tag" -m "$message" "$com_hash" && \
                                                             accomplished "$new_tag tag created, message: ${message}, for commit: $com_hash" ;;
              'delete all tags' ) if_locked
                                  git -C "${dest:-.}" tag | \
                                  xargs git -C "${dest:-.}" tag -d && \
                                  accomplished 'all tags deleted' ;;
              'delete a specific tag' ) get_input 'tag to delete' && tag="$input"
                                        if_locked
                                        git -C "${dest:-.}" tag -d "$tag" && \
                                        accomplished "$tag tag deleted" ;;
          esac ;;
          ## }}}
    revert )  ## {{{
             IFS=$'\n'
             if_locked
             preview_setting='hidden'
             readarray -t revert_items < <(git -C "${dest:-.}" log --pretty=oneline --color --abbrev-commit --date=relative \
                                           --pretty=format:'%Cblue%h%Creset %C(bold black)%cr%Creset%C(green)%d%Creset %s')
             revert_item="$(pipe_to_fzf_locally "${revert_items[@]}")" && wrap_fzf_choice "$revert_item" || exit 37
             revert_item="$(printf '%s\n' "$revert_item" | sed 's/ .*//g')"

             get_single_input "revert to ${revert_item}?" && revert_prompt="$single_input"
             case "$revert_prompt" in
                 y ) git -C "${dest:-.}" checkout "$revert_item" && \
                     accomplished "$revert_item reverted to" ;;
             esac ;;
             ## }}}
    commits )  ## {{{ tell how many times dirs/files have been commited (https://github.com/terminalforlife/BashConfig/blob/master/source/.bash_functions)
               readarray -t all < <(find "${dest:-.}" -mindepth 1 -maxdepth 1 ! -iname '*.git' | sort)  ## exceptionally used *.git instead of *.git* to keep .gitignore included
               for a in "${all[@]##*/}"; {
                   printf '%s %s\n' "$(wc -l < <(git -C "${dest:-.}" rev-list HEAD "$a"))" "$a"
               } | sort --numeric-sort --reverse | column  ## --numeric-sort is for comparing according to string numerical value
               ;;
               ## }}}
esac

exit

## ,-- git -C "${dest:-.}" reset --soft HEAD^ : remove the last one commit but keep all the staged and unstaged files as they were.
## |-- git -C "${dest:-.}" reset --hard HEAD^ : remove the last one commit and undo also all the staged and instaged files before that. In fact it jumps back to the commit before the last one.
## '----> '^' means one commit, '^^' means two commits, and so on
