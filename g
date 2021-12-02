#!/usr/bin/env bash

## last modified: 1400-09-11 16:17:51 +0330 Thursday

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color
source "$HOME"/scripts/gb-git

title="${0##*/}"
noproxy='false'

function display_help {  ## {{{
    source "$HOME"/scripts/.help
    g_help
}
## }}}
function if_locked {  ## {{{
    [ -f "$directory"/.git/index.lock ] && {
        red 'locked'  ## 
        exit
    }
}
## }}}
function check_pattern {  ## {{{
    matches="$(find "$directory" -mindepth 1 -iname "$pattern")"   ## -maxdepth 1 is not needed here
    [ ! "$matches" ] && red 'no such pattern' && exit
}
## }}}
function if_amend_allowed {  ## {{{
    (( "$(git_commits_ahead "$directory")" == 0 )) && red 'amend not allowed' && exit
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
    local stts="$(git_status "$directory")"
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
    local short_pwd="${PWD/$HOME/\~}"
    local short_directory="${directory/$HOME/\~}"
    export directory2="$directory"  ## JUMP_3 we have to do the export because --preview uses subshell making the original directory useless here
                                         ##        we have to do the sourcing for the very same reason
    local fzf_choice="$(printf '%s\n' "$@" | fzf --header "git in ${short_directory:-$short_pwd}" --nth 2..,.. \
                                                 --preview-window "$preview_status" \
                                                 --preview '(source "$HOME"/scripts/gb-git; git_diff_specific "${directory2:-.}" {-1})')"
                                                 ## ^^ ORIG: --preview '(source "$HOME"/scripts/gb-git; git_diff_specific "${directory2:-.}" {-1}; cat {-1}) | head -500'
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}
## }}}
function branch_info {  ## {{{ https://revelry.co/terminal-workflow-fzf/
    export directory2="$directory"  ## JUMP_3 we have to do the export because --preview uses subshell making the original directory useless here
                                         ##        we have to do the sourcing for the very same reason
    ## no need to --preview-window "$preview_status" because it uses the value set in bahrc in FZF_DEFAULT_OPTS
    local fzf_choice="$(printf '%s\n' "$@" | fzf \
                        --preview 'source "$HOME"/scripts/gb-git; git_log "${directory2:-.}" \
                        $(sed s/^..// <<< {} | cut -d " " -f 1)' | sed 's/^..//' | cut -d " " -f 1
                        ## ^^ ORIG: --preview 'git -C "${directory2:-.}" log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d " " -f 1) | head -'$LINES | sed 's/^..//'
                      )"
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}
## }}}
function branches_array {  ## {{{
    declare -a branches_list
    readarray -t branches_list < <(git_branches "$directory")  ## branches
    printf '%s\n' "${branches_list[@]}"
}
## }}}
function prompt {  ## {{{
    for args in "$@"; {
        case "$1" in
            -p ) [ ! "$pattern"     ] && get_input 'Pattern'     && pattern="$input"; check_pattern ;;
            -m ) [ ! "$message"     ] && get_input 'Message'     && message="$input"     ;;
            -b ) [ ! "$branch"      ] && get_input 'Branch'      && branch="$input"      ;;
            -t ) [ ! "$tag"         ] && get_input 'Tag'         && tag="$input"         ;;
            -c ) [ ! "$commit_hash" ] && get_input 'Commit hash' && commit_hash="$input" ;;
        esac
        shift
    }
}
## }}}
function get_opt {  ## {{{
    local options="$(getopt --longoptions 'help,noproxy,pattern:message:,branch:,tag:,commit-hash:' --options 'hnp:m:b:t:c:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )        display_help            ;;
            -n|--noproxy )     noproxy='true'          ;;
            -p|--pattern )     shift; pattern="$1"     ;;
            -m|--message )     shift; message="$1"     ;;
            -b|--branch )      shift; branch="$1"      ;;
            -t|--tag )         shift; tag="$1"         ;;
            -c|--commit-hash ) shift; commit_hash="$1" ;;
            -- )               break                   ;;
        esac
        shift
    done
}
## }}}

get_opt "$@"
heading "$title"

readarray -t repositories < <(git_repositories)
repository="$(pipe_to_fzf "${repositories[@]}")" && wrap_fzf_choice "$repository" || exit 37
directory="${repository/\~/$HOME}"

if_locked

main_items=( 'status' 'add' 'commit' 'add_commit' 'commit_amend' 'undo' 'unstage' 'log' 'push' 'edit' 'empty_commit' 'remove' 'branch' 'tag' 'remotes' 'revert' 'commits' 'help' )
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
              pattern ) prompt -p
                        if_locked
                        git_add_specific_or_pattern "$directory" "$pattern" && \
                        accomplished "$pattern added" ;;
              all )     if_locked
                        git_add_all "$directory" && \
                        accomplished 'all added' ;;
              * )       add_item="${add_item:2}"  ## JUMP_1 :2 to remove '[] ' from the beginning
                        if_locked
                        git_add_specific_or_pattern "$directory" "$add_item" && \
                        accomplished "$add_item added" ;;
          esac ;;
          ## }}}
    commit )  ## {{{
             if_changed
             [ ! "$sta" ] && red 'no staged files' && exit  ## checking if array is empty. no need to [@]

             preview_status='hidden'
             commmit_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$commit_item" || exit 37

             case "$commmit_item" in
                 "open $editor" ) if_locked
                                  git_commit_in_editor "$directory" && \
                                  accomplished "committed in $editor" ;;
                 'write here' ) prompt -m
                                if_locked
                                git_commit_with_message "$directory" "$message" \
                                accomplished "committed, message: $message" ;;
             esac ;;
             ## }}}
    add_commit ) ## {{{
                 if_changed
                 add_commit_item="$(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all' 'all + amend')" && wrap_fzf_choice "$add_commit_item" || exit 37

                 case "$add_commit_item" in
                     pattern ) prompt -p -m
                               if_locked
                               git_add_specific_or_pattern "$directory" "$pattern" && \
                               git_commit_with_message "$directory" "${pattern}: $message" && \
                               accomplished "$pattern added, message: ${pattern}: $message" ;;
                     all ) prompt -m
                           if_locked
                           git_add_all "$directory" && \
                           git_commit_with_message "$directory" "MANY: $message" && \
                           accomplished "all added, message: MANY: $message" ;;
                     'all + amend' ) if_amend_allowed
                                     if_locked
                                     git_add_all "$directory" && \
                                     git_commit_amend "$directory" && \
                                     accomplished "all added, commit amended in $editor" ;;
                     * ) prompt -m
                         add_commit_item="${add_commit_item:2}"  ## JUMP_1 :2 to remove '[] ' from the beginning
                         if_locked
                         git_add_specific_or_pattern "$directory" "$add_commit_item" && \
                         git_commit_with_message "$directory" "${add_commit_item}: $message" && \
                         accomplished "$add_commit_item added, message: ${add_commit_item}: $message" ;;
                 esac ;;
                 ## }}}
    commit_amend )  ## {{{
                   if_amend_allowed
                   preview_status='hidden'
                   commit_amend_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$commit_amend_item" || exit 37

                   case "$commit_amend_item" in
                       "open $editor" ) if_locked
                                        git_commit_amend "$directory" && \
                                        accomplished "commit amended in $editor" ;;
                       'write here' ) prompt -m
                                      if_locked
                                      git_commit_amend_with_message "$directory" "$message" && \
                                      accomplished "commit amended, message: $message" ;;
                   esac ;;
                   ## }}}
    undo )  ## {{{
           if_changed
           undo_item="$(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all')" && wrap_fzf_choice "$undo_item" || exit 37

           case "$undo_item" in
                pattern ) prompt -p
                          if_locked
                          git_undo_specific_or_pattern "$directory" "$pattern" && \
                          accomplished "$pattern undid" ;;
                all )     if_locked
                          git_undo_all "$directory" && \
                          accomplished "all undid" ;;
                * )       undo_item="${undo_item:2}"  ## JUMP_1 :2 to remove '[] ' from the beginning
                          if_locked
                          git_undo_specific_or_pattern "$directory" "$undo_item" && \
                          accomplished "$undo_item undid" ;;
           esac ;;
           ## }}}
    unstage )  ## {{{
              if_changed
              [ ! "$sta" ] && red 'no staged files' && exit  ## checking if array is empty. no need to [@]

              preview_status='hidden'
              unstage_item="$(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all')" && wrap_fzf_choice "$unstage_item" || exit 37

              case "$unstage_item" in
                  pattern ) prompt -p
                            if_locked
                            git_unstage_specific_or_pattern "$directory" "$pattern" && \
                            accomplished "$pattern unstaged" ;;  ## unstage a pattern
                  all )     if_locked
                            git_unstage_all "$directory" && \
                            accomplished 'all unstaged' ;;  ## unstage all staged files
                  * )       unstage_item="${unstage_item:2}"  ## JUMP_1 :2 to remove '[] ' from the beginning
                            if_locked
                            git_unstage_specific_or_pattern "$directory" "$unstage_item" && \
                            accomplished "$unstage_item unstaged" ;;
              esac ;;
              ## }}}
    log )  ## {{{
          IFS=$'\n'
          if_locked
          preview_status='hidden'
          readarray -t log_items < <(git_log "$directory")
          pipe_to_fzf_locally "${log_items[@]}" ;;
          ## }}}
    push )  ## {{{
           if [ "$(git_remotes "$directory")" ]; then
               if_locked
               if [ "$noproxy" == 'false' ]; then
                   git_push_proxy "$directory" && \
                   accomplished 'pushed with proxy'
               else
                   git_push_noproxy "$directory" && \
                   accomplished 'pushed with noproxy'
               fi
           else
               red 'no remote'
           fi ;;
           ## }}}
    edit )  ## {{{
           if_locked
           git_edit "$directory" && \
           accomplished 'edited' ;;
           ## }}}
    empty_commit )  ## commit with nothing staged {{{
                   preview_status='hidden'
                   empty_commit_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$empty_commit_item" || exit 37

                   case "$empty_commit_item" in
                       "open $editor" ) if_locked
                                        git_empty_commit "$directory" && \
                                        accomplished 'committed empty' ;;
                       'write here' ) prompt -m
                                      if_locked
                                      git_empty_commit_with_message "$directory" "$message" && \
                                      accomplished "committed empty, message: $message" ;;
                   esac ;;
                   ## }}}
    remove )  ## {{{
             prompt -p
             if_locked
             git_remove "$directory" "$pattern" && \
             accomplished "$pattern removed" ;;
             ## }}}
    branch )  ## {{{
             preview_status='hidden'
             branch_items=( 'show branches' 'create branch' 'checkout to a branch' 'delete all branches' 'force delete all branches' 'delete a specific branch' 'force delete a specific branch' )
             branch_item="$(pipe_to_fzf_locally "${branch_items[@]}")" && wrap_fzf_choice "$branch_item" || exit 37

             case "$branch_item" in
                 'show branches' ) if_locked
                                   # IFS=$'\n'
                                   branch_info "$(branches_array)" && accomplished ;;
                 'create branch' ) prompt -b
                                   if_locked
                                   git_branch_create "$directory" "$branch" && \
                                   accomplished "$branch branch created" ;;
                 'checkout to a branch' ) if_locked
                                          # IFS=$'\n'
                                          cd_to_branch_item="$(branch_info "$(branches_array)")"
                                          git_branch_checkout "$directory" "$cd_to_branch_item" && \
                                          accomplished "$cd_to_branch_item branch checkedout to" ;;
                 'delete all branches' ) if_locked
                                         readarray -t local_branches < <(git_branches_exclude_remote "$directory" | \grep -v 'master')
                                         git_branch_delete_all "$directory" "${local_branches[@]}" && \
                                         accomplished 'all branches deleted' ;;
                 'force delete all branches' ) if_locked
                                               readarray -t local_branches < <(git_branches_exclude_remote "$directory" | \grep -v 'master')
                                               git_branch_force_delete_all "$directory" "${local_branches[@]}" && \
                                               accomplished 'all branches force deleted' ;;
                 'delete a specific branch' ) if_locked
                                              # IFS=$'\n'
                                              delete_branch_item="$(branch_info "$(branches_array | \grep -v 'master')")" && wrap_fzf_choice "$delete_branch_item" || exit 37
                                              git_branch_delete_specific "$directory" "$delete_branch_item" && \
                                              accomplished "$delete_branch_item branch deleted" ;;
                 'force delete a specific branch' ) if_locked
                                                    # IFS=$'\n'
                                                    force_delete_branch_item="$(branch_info "$(branches_array | \grep -v 'master')")" && wrap_fzf_choice "$force_delete_branch_item" || exit 37
                                                    git_branch_force_delete_specific "$directory" "$force_delete_branch_item" && \
                                                    accomplished "$force_delete_branch_item branch force deleted" ;;
             esac ;;
             ## }}}
    tag )  ## {{{
          preview_status='hidden'
          tag_items=( 'show tags' 'show a specific tag' 'create tag' 'create tag + message' 'create tag + message for a specific commit' 'delete all tags' 'delete a specific tag')
          tag_item="$(pipe_to_fzf_locally "${tag_items[@]}")" && wrap_fzf_choice "$tag_item" || exit 37

          case "$tag_item" in
              'show tags' ) if_locked
                            git_tag_show_all "$directory" && \
                            accomplished ;;
              'show a specific tag' ) prompt -t
                                      if_locked
                                      git_tag_show_specific "$directory" "$tag" && \
                                      accomplished "$tag tag shown" ;;
              'create tag' ) prompt -t
                             tag="${tag// /_}"
                             if_locked
                             git_tag_create "$directory" "$tag" && \
                             accomplished "$tag tag created" ;;
              'create tag + message' ) prompt -t -m
                                       tag="${tag// /_}"
                                       if_locked
                                       git_tag_create_with_message "$directory" "$tag" "$message" && \
                                       accomplished "$tag tag created, message: $message" ;;
              'create tag + message for a specific commit' ) prompt -t -m -c
                                                             tag="${tag// /_}"
                                                             if_locked
                                                             git_tag_create_with_message_for_specific_commit "$directory" "$tag" "$message" "$commit_hash" && \
                                                             accomplished "$tag tag created, message: ${message}, for commit: $commit_hash" ;;
              'delete all tags' ) if_locked
                                  readarray -t all_tags < <(git_tag_show_all "$directory")
                                  git_tag_delete_all "$directory" "${all_tags[@]}" && \
                                  accomplished 'all tags deleted' ;;
              'delete a specific tag' ) prompt -t
                                        if_locked
                                        git_tag_delete_specific "$directory" "$tag" && \
                                        accomplished "$tag tag deleted" ;;
          esac ;;
          ## }}}
    remotes )
        git_remotes && \
        accomplished ;;
    revert )  ## {{{
             IFS=$'\n'
             if_locked
             preview_status='hidden'
             readarray -t revert_items < <(git_log "$directory")
             revert_item="$(pipe_to_fzf_locally "${revert_items[@]}")" && wrap_fzf_choice "$revert_item" || exit 37
             revert_item="$(printf '%s\n' "$revert_item" | sed 's/\* \([^ ]\+\) .*/\1/g')"

             get_single_input "revert to ${revert_item}?" && revert_prompt="$single_input"
             case "$revert_prompt" in
                 y ) git_revert "$directory" "$revert_item" && \
                     accomplished "$revert_item reverted to" ;;
             esac ;;
             ## }}}
    commits )  ## {{{ tell how many times dirs/files have been commited (https://github.com/terminalforlife/BashConfig/blob/master/source/.bash_functions)
               readarray -t dirs_files < <(find "$directory" -mindepth 1 -maxdepth 1 ! -iname '.git' | sort)  ## used .git (instead of .git*) to keep .gitignore included

               for df in "${dirs_files[@]##*/}"; {
                   printf '%s %s\n' "$(git_touched_count "$directory" "$df")" "$df"
               } | sort --numeric-sort --reverse | column  ## --numeric-sort is for comparing according to string numerical value
               ;;
               ## }}}
    help ) display_help  ## {{{
           ;;
           ## }}}
esac

exit

## ,-- git -C "$directory" reset --soft HEAD^ : remove the last one commit but keep all the staged and unstaged files as they were.
## |-- git -C "$directory" reset --hard HEAD^ : remove the last one commit and undo also all the staged and instaged files before that. In fact it jumps back to the commit before the last one.
## '----> '^' means one commit, '^^' means two commits, and so on
