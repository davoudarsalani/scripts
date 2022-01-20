#!/usr/bin/env bash

## @last-modified 1400-10-29 18:17:16 +0330 Wednesday

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color
source "$HOME"/scripts/gb-git

title="${0##*/}"

function display_help {
    source "$HOME"/scripts/.help
    g_help
}

function add_to_changes {
    local icon member
    declare -a received=( "$@" )

    icon="${received[0]}"
    unset 'received[0]'

    for member in "${received[@]}"; {
        changes+=( "${icon}---${member}" )
    }
}

function branch_info {
    local fzf_choice

    export directory2="$directory"  ## JUMP_3 we have to do the export because --preview uses subshell making the original directory useless here
                                         ##        we have to do the sourcing for the very same reason
    ## no need to --preview-window "$preview_status" because it uses the value set in bahrc in FZF_DEFAULT_OPTS
    fzf_choice="$(printf '%s\n' "$@" | fzf \
                  --preview 'source "$HOME"/scripts/gb-git; git_log "${directory2:-.}" \
                  $(sed s/^..// <<< {} | cut -d " " -f 1)' #| sed 's/^..//' | cut -d " " -f 1
                  ## ^^ ORIG: --preview 'git -C "${directory2:-.}" log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d " " -f 1) | head -'$LINES | sed 's/^..//'
                )"
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}

function branches_array {
    declare -a branches_list
    readarray -t branches_list < <(git_branches "$directory")  ## branches
    printf '%s\n' "${branches_list[@]}"
}

function check_pattern {
    matches="$(find "$directory" -mindepth 1 -iname "$pattern")"   ## -maxdepth 1 is not needed here
    [ "$matches" ] || {
        red 'no such pattern'
        exit
    }
}

function if_amend_allowed {
    (( "$(git_commits_ahead "$directory")" > 0 )) || {
        red 'amend not allowed'
        exit
    }
}

function if_changed {
    local stts

    changes=()  ## NOTE do NOT use declare -a changes since declare makes changes a local variable
    stts="$(git_status "$directory")"
    readarray -t mod   < <(printf '%s\n' "$stts" | \grep '^ M'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${mod[@]}"
    readarray -t del   < <(printf '%s\n' "$stts" | \grep '^ D'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${del[@]}"
    readarray -t ren   < <(printf '%s\n' "$stts" | \grep '^ R'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes 'Ⓡ' "${ren[@]}"
    readarray -t add   < <(printf '%s\n' "$stts" | \grep '^ A'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${add[@]}"
    readarray -t unt   < <(printf '%s\n' "$stts" | \grep '^??'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${unt[@]}"
    readarray -t upd   < <(printf '%s\n' "$stts" | \grep '^UU'           | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${upd[@]}"  ## updated but unmerged
    readarray -t sta   < <(printf '%s\n' "$stts" | \grep '^[MDRA] '      | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${sta[@]}"
    readarray -t sta_m < <(printf '%s\n' "$stts" | \grep '^[MDRA][MDRA]' | awk '{print $2}' | sed 's/\/$//'); add_to_changes '' "${sta_m[@]}"

    [ "${changes[0]}" ] || {
        green 'sleeping'
        exit
    }
}

function if_locked {
    [ -f "$directory"/.git/index.lock ] && {
        red 'locked'  ## 
        exit
    }
}

function pipe_to_fzf_locally {
    local fzf_choice short_pwd short_directory

    [ "$multiple" == 'true' ] && multi_arg='--multi'
    short_pwd="${PWD/$HOME/\~}"
    short_directory="${directory/$HOME/\~}"
    export directory2="$directory"  ## JUMP_3 we have to do the export because --preview uses subshell making the original directory useless here
                                    ##        we have to do the sourcing for the very same reason
    fzf_choice="$(printf '%s\n' "$@" | fzf --header "git in ${short_directory:-$short_pwd}" --nth 2..,.. \
                                           --preview-window "$preview_status" \
                                           ${multi_arg} \
                                           --preview '(source "$HOME"/scripts/gb-git; git_diff_specific "${directory2:-.}" {-1})')"
                                           ## ^^ ORIG: --preview '(source "$HOME"/scripts/gb-git; git_diff_specific "${directory2:-.}" {-1}; cat {-1}) | head -500'
    [ "$fzf_choice" ] && printf '%s\n' "$fzf_choice" || return 37
}

function wrap_fzf_multi {
    no_sign_arr=( "${@#* }" )  ## remove '[Ⓡ] ' from the beginning
    colonized="$(printf '%s:' "${no_sign_arr[@]}")"
    wrap_fzf_choice "$colonized"
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -p )
                pattern="${pattern:-"$(get_input 'Pattern (e.g. *.py)')"}"  ## NOTE pattern does NOT need quotes here, but if pattern is passed as arg, it will
                check_pattern ;;
            -m )
                message="${message:-"$(get_input 'Message')"}" ;;
            -b )
                branch="${branch:-"$(get_input 'Branch')"}" ;;
            -t )
                tag="${tag:-"$(get_input 'Tag')"}" ;;
            -c )
                commit_hash="${commit_hash:-"$(get_input 'Commit hash')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,proxy,directory:,pattern:,message:,branch:,tag:,commit-hash:' --options 'hxd:p:m:b:t:c:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -x|--proxy )
                proxy='true' ;;
            -d|--directory )
                shift
                directory="$1" ;;
            -p|--pattern )
                shift
                pattern="$1" ;;
            -m|--message )
                shift
                message="$1" ;;
            -b|--branch )
                shift
                branch="$1" ;;
            -t|--tag )
                shift
                tag="$1" ;;
            -c|--commit-hash )
                shift
                commit_hash="$1" ;;
            -- )
                break ;;
        esac
 shift
    done
}


proxy='false'

get_opt "$@"
heading "$title"

main_items=( 'status' 'add [+]' 'commit' 'add_commit [+]' 'commit_amend' 'undo [+]' 'unstage [+]' 'log' 'push' 'pull' 'empty_commit' 'remove' 'branch' 'tag' 'remotes' 'jump back' 'garbage clean' 'commits' 'config' 'add all, commit updated, push' "setup in ${PWD/$HOME/\~}" 'help' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    help )
        display_help ;;

    "setup in ${PWD/$HOME/\~}" )
        test_dir="$PWD"
        [ -d "$test_dir"/.git ] && {
            red "${test_dir/$HOME/\~}/.git already exists"
            exit
        }
        start_init="$(get_single_input 'start?')" && printf '\n'
        case "$start_init" in
            y )
                {
                    action_now 'create README.md'
                    [ -f "$test_dir"/README.md ] || echo "# ${test_dir##*/}" >> "$test_dir"/README.md
                    action_now 'init'
                    git -C "$test_dir" init &>/dev/null
                    action_now 'add all'
                    git_add_all "$test_dir"
                    action_now "commit 'initiated'"
                    git_commit_with_message "$test_dir" 'initiated' &>/dev/null
                    action_now 'set master'
                    git -C "$test_dir" branch -M master
                    action_now "add origin https://www.github.com/${github_username}/${test_dir##*/}.git"
                    git -C "$test_dir" remote add origin https://www.github.com/${github_username}/${test_dir##*/}.git
                    printf "%s  curl -X POST -H \"Authorization: token \${github_token}\" https://api.github.com/user/repos -d '{\"name\": \"%s\"}' &>/dev/null\n" "$(blue 'create remote')" "${test_dir##*/}"
                    printf "               curl -X POST -H \"Authorization: token \${github_token}\" https://api.github.com/user/repos -d '{\"name\": \"%s\", \"private\": \"true\"}' &>/dev/null\n" "${test_dir##*/}"
                    # printf "              curl -su \"${github_username}:\$github_token\" https://api.github.com/user/repos -d '{\"name\": \"%s\"}'\n" "${test_dir##*/}"
                    # printf "              curl -su \"${github_username}:\$github_token\" https://api.github.com/user/repos -d '{\"name\": \"%s\", \"private\": \"true\"}'\n" "${test_dir##*/}"
                    printf '%s git -C %s push -u origin master\n' "$(blue 'push to remote')" "${test_dir/$HOME/\~}"
                    printf "%s  curl -X DELETE -H \"Authorization: token \${github_token}\" https://api.github.com/repos/${github_username}/%s\n" "$(orange 'remove remote')" "${test_dir##*/}"
                } && accomplished
            ;;
        esac
        exit ;;

    config )
        see_edit="$(pipe_to_fzf_locally 'see' 'edit')" && wrap_fzf_choice "$see_edit" || exit 37
        case "$see_edit" in
            see )
                git_config_see ;;
            edit )
                if_locked
                git_edit_config "$directory" && \
                accomplished 'edited' ;;
        esac
        exit ;;

esac

if [ "$directory" ]; then
    [ "$(if_git "$directory")" == 'true' ] || {
        red 'no git'
        exit
    }
else
    directory="$(choose_directory 'git')" && wrap_fzf_choice "${directory/$HOME/\~}" || exit 37
    # directory="${directory/\~/$HOME}"
fi

if_locked

case "$main_item" in
    status )
        if_changed
        pipe_to_fzf_locally "${changes[@]/---/' '}" && accomplished ;;

    'add [+]' )
        if_changed
        IFS=$'\n'
        multiple='true'
        add_items=( $(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all') ) && wrap_fzf_multi "${add_items[@]}" || exit 37

        case "${no_sign_arr[@]}" in
            pattern )
                prompt -p
                if_locked
                git_add_specific_or_pattern "$directory" "$pattern" && \
                accomplished "$pattern added" ;;
            all )
                if_locked
                git_add_all "$directory" && \
                accomplished 'all added' ;;
            * )
                if_locked
                for i in "${no_sign_arr[@]}"; {
                    git_add_specific_or_pattern "$directory" "$i"
                    accomplished "$i added"
                    (:)
                } ;;
        esac ;;

    commit )
        if_changed
        [ "${sta[0]}" ] || {
            red 'no staged files'
            exit
        }

        preview_status='hidden'
        commit_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$commit_item" || exit 37

        case "$commit_item" in
            "open $editor" )
                if_locked
                git_commit_in_editor "$directory" && \
                accomplished "committed in $editor" ;;
            'write here' )
                prompt -m
                if_locked
                git_commit_with_message "$directory" "$message" && \
                accomplished "committed, message: $message" ;;
        esac ;;

    'add_commit [+]' )
        if_changed
        IFS=$'\n'
        multiple='true'
        add_commit_items=( $(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all' 'all+amend') ) && wrap_fzf_multi "${add_commit_items[@]}" || exit 37

        case "${no_sign_arr[@]}" in
            pattern )
                prompt -p -m
                if_locked
                git_add_specific_or_pattern "$directory" "$pattern" && \
                git_commit_with_message "$directory" "${pattern}: $message" && \
                accomplished "$pattern added, message: ${pattern}: $message" ;;
            all )
                prompt -m
                if_locked
                git_add_all "$directory" && \
                git_commit_with_message "$directory" "MANY: $message" && \
                accomplished "all added, message: MANY: $message" ;;
            'all+amend' )
                if_amend_allowed
                if_locked
                git_add_all "$directory" && \
                git_commit_amend "$directory" && \
                accomplished "all added, commit amended in $editor" ;;
            * )
                prompt -m
                if_locked
                for i in "${no_sign_arr[@]}"; {
                   git_add_specific_or_pattern "$directory" "$i"
                   accomplished "$i added"
                   (:)
                }
                git_commit_with_message "$directory" "$colonized $message" && \
                accomplished "message: $colonized $message" ;;
        esac ;;

    commit_amend )
        if_amend_allowed
        preview_status='hidden'
        commit_amend_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$commit_amend_item" || exit 37

        case "$commit_amend_item" in
            "open $editor" )
                if_locked
                git_commit_amend "$directory" && \
                accomplished "commit amended in $editor" ;;
            'write here' )
                prompt -m
                if_locked
                git_commit_amend_with_message "$directory" "$message" && \
                accomplished "commit amended, message: $message" ;;
        esac ;;

    'undo [+]' )
        if_changed
        IFS=$'\n'
        multiple='true'
        undo_items=( $(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all') ) && wrap_fzf_multi "${undo_items[@]}" || exit 37

        case "${no_sign_arr[@]}" in
             pattern )
                prompt -p
                if_locked
                git_undo_specific_or_pattern "$directory" "$pattern" && \
                accomplished "$pattern undid" ;;
             all )
                if_locked
                git_undo_all "$directory" && \
                accomplished "all undid" ;;
             * )
                if_locked
                for i in "${no_sign_arr[@]}"; {
                    git_undo_specific_or_pattern "$directory" "$i"
                    accomplished "$i undid"
                    (:)
                } ;;
        esac ;;

    'unstage [+]' )
        if_changed
        [ "${sta[0]}" ] || {
            red 'no staged files'
            exit
        }
        IFS=$'\n'
        multiple='true'
        preview_status='hidden'

        unstage_items=( $(pipe_to_fzf_locally "${changes[@]/---/' '}" 'pattern' 'all') ) && wrap_fzf_multi "${unstage_items[@]}" || exit 37

        case "${no_sign_arr[@]}" in
            pattern )
                prompt -p
                if_locked
                git_unstage_specific_or_pattern "$directory" "$pattern" && \
                accomplished "$pattern unstaged" ;;
            all )
                if_locked
                git_unstage_all "$directory" && \
                accomplished 'all unstaged' ;;
            * )
                if_locked
                for i in "${no_sign_arr[@]}"; {
                    git_unstage_specific_or_pattern "$directory" "$i"
                    accomplished "$i unstaged"
                    (:)
                } ;;
        esac ;;

    log )
        IFS=$'\n'
        if_locked
        preview_status='hidden'
        readarray -t log_items < <(git_log "$directory")
        pipe_to_fzf_locally "${log_items[@]}" ;;

    push )
        if_locked
        if [ "$(git_remotes "$directory")" ]; then
            git_if_behind "$directory"
            if_locked
            if [ "$proxy" == 'true' ]; then
                git_push_proxy "$directory" && \
                accomplished 'pushed with proxy'
            else
                git_push_noproxy "$directory" && \
                accomplished 'pushed without proxy'
            fi
        else
            red 'no remote'
        fi ;;

    pull )
        if_locked
        if [ "$proxy" == 'true' ]; then
            git_pull_proxy "$directory" && \
            accomplished 'pulled with proxy'
        else
            git_pull_noproxy "$directory" && \
            accomplished 'pulled without proxy'
        fi ;;

    empty_commit )
        preview_status='hidden'
        empty_commit_item="$(pipe_to_fzf_locally "open $editor" 'write here')" && wrap_fzf_choice "$empty_commit_item" || exit 37

        case "$empty_commit_item" in
            "open $editor" )
                if_locked
                git_empty_commit "$directory" && \
                accomplished 'committed empty' ;;
            'write here' )
                prompt -m
                if_locked
                git_empty_commit_with_message "$directory" "$message" && \
                accomplished "committed empty, message: $message" ;;
        esac ;;

    remove )
        prompt -p
        if_locked
        git_remove "$directory" "$pattern" && \
        accomplished "$pattern removed" ;;

    branch )
        preview_status='hidden'
        branch_items=( 'show branches' 'create branch' 'switch to a branch' 'create branch and switch to it' 'delete all branches' 'force delete all branches' 'delete a specific branch' 'force delete a specific branch' )
        branch_item="$(pipe_to_fzf_locally "${branch_items[@]}")" && wrap_fzf_choice "$branch_item" || exit 37

        case "$branch_item" in
            'show branches' )
                if_locked
                # IFS=$'\n'
                branch_info "$(branches_array)" && accomplished ;;
            'create branch' )
                prompt -b
                if_locked
                git_branch_create "$directory" "$branch" && \
                accomplished "$branch branch created" ;;
            'switch to a branch' )
                if_locked
                # IFS=$'\n'
                cd_to_branch_item="$(branch_info "$(branches_array)")"
                git_branch_switch "$directory" "$cd_to_branch_item" && \
                accomplished "$cd_to_branch_item branch switched to" ;;
            'create branch and switch to it' )
                prompt -b
                if_locked
                git_branch_create "$directory" "$branch" && \
                git_branch_switch "$directory" "$branch" && \
                accomplished "$branch branch created and switched to" ;;
            'delete all branches' )
                if_locked
                readarray -t local_branches < <(git_branches_exclude_remote "$directory" | \grep -v 'master')
                git_branch_delete_all "$directory" "${local_branches[@]}" && \
                accomplished 'all branches deleted' ;;
            'force delete all branches' )
                if_locked
                readarray -t local_branches < <(git_branches_exclude_remote "$directory" | \grep -v 'master')
                git_branch_force_delete_all "$directory" "${local_branches[@]}" && \
                accomplished 'all branches force deleted' ;;
            'delete a specific branch' )
                if_locked
                # IFS=$'\n'
                delete_branch_item="$(branch_info "$(branches_array | \grep -v 'master')")" && wrap_fzf_choice "$delete_branch_item" || exit 37
                git_branch_delete_specific "$directory" "$delete_branch_item" && \
                accomplished "$delete_branch_item branch deleted" ;;
            'force delete a specific branch' )
                if_locked
                # IFS=$'\n'
                force_delete_branch_item="$(branch_info "$(branches_array | \grep -v 'master')")" && wrap_fzf_choice "$force_delete_branch_item" || exit 37
                git_branch_force_delete_specific "$directory" "$force_delete_branch_item" && \
                accomplished "$force_delete_branch_item branch force deleted" ;;
        esac ;;

    tag )
        yellow_dim 'WARNING: You have to manually push tags by: git -C GITPATH push origin tag TAGNAME'

        preview_status='hidden'
        tag_items=( 'show tags' 'show a specific tag' 'create tag' 'create tag + message' 'create tag + message for a specific commit' 'delete all tags' 'delete a specific tag')
        tag_item="$(pipe_to_fzf_locally "${tag_items[@]}")" && wrap_fzf_choice "$tag_item" || exit 37

        case "$tag_item" in
            'show tags' )
                if_locked
                git_tag_show_all "$directory" && \
                accomplished ;;
            'show a specific tag' )
                prompt -t
                if_locked
                git_tag_show_specific "$directory" "$tag" && \
                accomplished "$tag tag shown" ;;
            'create tag' )
                prompt -t
                tag="${tag// /_}"
                if_locked
                git_tag_create "$directory" "$tag" && \
                accomplished "$tag tag created" ;;
            'create tag + message' )
                prompt -t -m
                tag="${tag// /_}"
                if_locked
                git_tag_create_with_message "$directory" "$tag" "$message" && \
                accomplished "$tag tag created, message: $message" ;;
            'create tag + message for a specific commit' )
                prompt -t -m -c
                tag="${tag// /_}"
                if_locked
                git_tag_create_with_message_for_specific_commit "$directory" "$tag" "$message" "$commit_hash" && \
                accomplished "$tag tag created, message: ${message}, for commit: $commit_hash" ;;
            'delete all tags' )
                if_locked
                readarray -t all_tags < <(git_tag_show_all "$directory")
                git_tag_delete_all "$directory" "${all_tags[@]}" && \
                accomplished 'all tags deleted' ;;
            'delete a specific tag' )
                prompt -t
                if_locked
                git_tag_delete_specific "$directory" "$tag" && \
                accomplished "$tag tag deleted" ;;
        esac ;;

    remotes )
        git_remotes && \
        accomplished ;;

    'jump back' )
        jump_items=( 'reset soft' 'reset mixed' 'reset hard' 'revert' )
        jump_item="$(pipe_to_fzf_locally "${jump_items[@]}")" && wrap_fzf_choice "$jump_item" || exit 37

        if_locked
        IFS=$'\n'
        preview_status='hidden'
        readarray -t log_items < <(git_log "$directory")
        log_item="$(pipe_to_fzf_locally "${log_items[@]}")" && wrap_fzf_choice "$log_item" || exit 37
        log_item="$(printf '%s\n' "$log_item" | sed 's/\* \([^ ]\+\) .*/\1/g')"

        jump_prompt="$(get_single_input "$jump_item to ${log_item}?")" && printf '\n'
        [ "$jump_prompt" == 'y' ] || exit

        case "$jump_item" in
            'reset soft' )
                git_reset_soft "$directory" "$log_item" && \
                accomplished "$log_item reset soft to" ;;
            'reset mixed' )
                git_reset_mixed "$directory" "$log_item" && \
                accomplished "$log_item reset mixed to" ;;
            'reset hard' )
                git_reset_hard "$directory" "$log_item" && \
                accomplished "$log_item reset hard to" ;;
            revert )
                git_revert "$directory" "$log_item" && \
                accomplished "$log_item reverted to" ;;
        esac ;;

    'garbage clean' )
        clean_prompt="$(get_single_input 'sure?')" && printf '\n'
        case "$clean_prompt" in
            y )
                git_garbage_clean "$directory" && \
                accomplished 'garbage cleaned' ;;
        esac ;;

    commits )
        readarray -t items < <(find "$directory" -mindepth 1 -maxdepth 1 ! -iname '.git' | sort)  ## used .git (instead of .git*) to keep .gitignore included

        for df in "${items[@]##*/}"; {
            printf '%s %s\n' "$(git_touched_count "$directory" "$df")" "$df"
        } | sort --numeric-sort --reverse | column && \
        accomplished ;;  ## --numeric-sort is for comparing according to string numerical value

    'add all, commit updated, push' )
        [ "$directory" == '.' ] && directory="$PWD"
        if ! \grep -q 'public' <<< "$directory"; then
            red 'public repositories only'
            exit
        fi

        git_if_behind "$directory"
        if_changed
        git_add_all "$directory" && \
        git_commit_with_message "$directory" 'updated' && \
        git_push_noproxy "$directory" && \
        accomplished ;;

esac
