#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-git.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-git.sh
##    https://davoudarsalani.ir

# NOTE assigning dest="${1:-.}" and using git -C "$dest" instead of git -C "${1:-.}" did not work

## %x09 = tab (https://stackoverflow.com/questions/1441010/the-shortest-possible-output-from-git-log-containing-author-and-date)
##            (https://git-scm.com/docs/pretty-formats)

function if_git {
    git -C "${1:-.}" rev-parse --is-inside-work-tree &>/dev/null && printf 'true\n' || printf 'false\n'
}


function git_diff_all {
    ## NOTE nearly share the same options for diff as JUMP_2
    git -C "${1:-.}" diff --unified=0 --color=always --src-prefix=1st: --dst-prefix=2nd: | less -R
    ## --unified=0 makes git show only the modified lines
    ## --color-words show modified words side-by-side
}

function git_diff_specific {
    ## NOTE nearly share the same options for diff as JUMP_2
    git -C "${1:-.}" diff --unified=0 --color=always --src-prefix=1st: --dst-prefix=2nd: -- "$2" | sed 1,4d  ## $2 is item name
    ## --unified=0 makes git show only the modified lines
    ## --color-words show modified words side-by-side
}

function git_log {
    ## NOTE nearly share the same options for log as JUMP_1

    ## %G?: show "G" for a good (valid) signature, "B" for a bad signature, "U" for a good signature with unknown validity and "N" for no signature
    git -C "${1:-.}" \
        log --color --abbrev-commit --full-history --all --graph \
            --format='%C(always,blue)%h %C(always,magenta)%G? %C(always,bold black)%>(15,trunc)%cr %C(always,green)%<(4,trunc)%cn %C(always,green)%d %C(always,reset)%s'
}

function git_reflog {
    ## NOTE nearly share the same options for log as JUMP_1
    git -C "${1:-.}" \
        reflog --color --abbrev-commit --full-history \
               --format='%C(always,yellow)%h %C(always,magenta)%G? %C(always,bold black)%>(15,trunc)%cr %C(always,green)%<(4,trunc)%cn %C(always,green)%d %C(always,reset)%s'
}

function git_show { show changes for a commit
    git -C "${1:-.}" show --unified=0 --color=always "$2"  ## $2 is commit hash
    ## --unified=0 makes git show only the modified lines
    ## --color-words show modified words side-by-side
}


function git_add_all {
    git -C "${1:-.}" add -A
}

function git_add_specific_or_pattern {
    git -C "${1:-.}" add "$2"  ## $2 is item/pattern
}

function git_branch_create {
    git -C "${1:-.}" branch "$2"  ## $2 is branch
}

function git_branch_delete_all {
    git -C "${1:-.}" branch -d "${@:2}"  ## ${@:2} is branches
}

function git_branch_delete_specific {
    git -C "${1:-.}" branch -d "$2"  ## $2 is branch
}

function git_branch_force_delete_all {
    git -C "${1:-.}" branch -D "${@:2}"  ## ${@:2} is branches
}

function git_branch_force_delete_specific {
    git -C "${1:-.}" branch -D "$2"  ## $2 is branch
}

function git_branch_rename {
    git -C "${1:-.}" branch -m "$2" "$3"  ## $2 and $3 are current and new name of branch
}

function git_branch_switch {
    git -C "${1:-.}" switch "$2"  ## $2 is branch
}

function git_branches {
    git -C "${1:-.}" branch -a --color=always | \grep -v '/HEAD\s' | sed 's/^ \+//' | sort
}

function git_branches_exclude_remote {
    git -C "${1:-.}" branch | sed 's/^ \+//' | sort
}

function git_commit_in_editor {
    git -C "${1:-.}" commit
}

function git_commit_amend_in_vim {
    git -C "${1:-.}" commit --amend  ## opens editor
}

function git_commit_amend_auto {  ## without having to open vim
    ## https://github.com/clokep/dotfiles/blob/main/.gitconfig
    git -C "${1:-.}" commit --amend -C HEAD  ## opens editor
}

function git_commit_amend_with_message {
    git -C "${1:-.}" commit --amend -m "$2"  ## $2 is message
}

function git_commit_with_message {
    git -C "${1:-.}" commit -m "$2"  ## $2 is message
}

function git_commits_ahead {
    local commits_ahead

    commits_ahead="$(git -C "${1:-.}" branch -v | \grep 'ahead' | \grep -ioP '(?<=\[).*?(?=\])' | awk '{print $2}')"
    ## ^^ previously: git -C "${1:-.}" status -s | sed '1q;d' | \grep -i 'ahead' | awk '{print $NF}' | sed 's/[^0-9]//g'
    [ "$commits_ahead" ] && printf '%s\n' "$commits_ahead" || printf '0\n'
}

## getting the total number of "different" commits between local and remote (https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git):
function git_commits_behind_ahead {
    local current_branch

    current_branch="$(git_current_branch "${1:-.}")"
    git -C "${1:-.}" rev-list HEAD...origin/"$current_branch" --count
}

function git_commits_count {
    git -C "${1:-.}" rev-list HEAD --count
}

function git_commits_count_specific {
    git -C "${1:-.}" rev-list HEAD --count "$2"  ## $2 is item name
}

function git_config_edit {
    git -C "${1:-.}" config -e
}

function git_config_see {
    git config --list  ## no need to -C "${1:-.}"
}

function git_current_branch {
    git -C "${1:-.}" branch | sed -n '/\* /s///p'
    ## OR 1: git -C "${1:-.}" branch -a 2>/dev/null | sed '/^[^*]/d;s/* \(.*\)/\1/')"
    ##    2: git -C "${1:-.}" rev-parse --abbrev-ref HEAD  ## FIXME only returns HEAD instead of (HEAD detached at 56bb92a) when reverted to a commit
}

function git_empty_commit {
    git -C "${1:-.}" commit --allow-empty -n  ## opens editor
}

function git_empty_commit_with_message {
    git -C "${1:-.}" commit --allow-empty -n -m "$2"  ## $2 is message
}

function git_garbage_clean {
    git -C "${1:-.}" gc --prune=now --aggressive
}

function git_hash_head {
    git -C "${1:-.}" log -1 --format=%h
    ## PREVIOUSLY: git -C "${1:-.}" rev-parse --short --verify HEAD
}

function git_hash_last_commit {
    git -C "${1:-.}" log -1 --format=%h --all
}

function git_if_behind {
    source ~/main/scripts/gb-color.sh
    local commits_ahead commits_behind commits_behind_ahead temp_path

    action_now 'updating remote'
    commits_ahead="$(git_commits_ahead "${1:-.}")"
    if [ "$proxy" == 'true' ]; then
        git_remote_update_proxy "${1:-.}"
    else
        git_remote_update_noproxy "${1:-.}"
    fi
    commits_behind_ahead="$(git_commits_behind_ahead "${1:-.}")"

    ## getting commits_behind
    (( commits_behind="commits_behind_ahead - commits_ahead" ))
    (( commits_behind > 0 )) && {
        temp_path="$(printf '%s\n' "${1:-.}" | sed "s|$HOME|\~|")"  ## NOTE do NOT replace | with / in sed
        red "local is $commits_behind commits behind remote."
        red "try: git -C $temp_path pull"
        exit 37
    }
}

function git_last_commit {  ## returns last commit in repo
    ## usage:
    ##     git_last_commit 'repo_path'         ## returns date/time of last commit in repo
    ##     git_last_commit 'repo_path' 'item'  ## returns date/time item was last committed

    git -C "${1:-.}" log -1 --format=%ci "${2:-.}"  ## . in "${2:-.}" does nothing but preventing errors if there is no $2 passed
}

function git_pull_noproxy {
    git -C "${1:-.}" pull
}

function git_pull_proxy {
    torsocks git -C "${1:-.}" pull
}

function git_push_failed {
    source ~/main/scripts/gb-color.sh

    red 'push failed.'
    red "try: git -C ${1:-.} push --set-upstream origin master"  ## --set-upstream or -u
}

function git_push_noproxy {
    git -C "${1:-.}" push || git_push_failed
}

function git_push_proxy {
    torsocks git -C "${1:-.}" push || git_push_failed
}

function git_relative_head {
    git -C "${1:-.}" log -1 --format=%cr | sed 's/minute/min/;s/hour/hr/;s/ /-/g'
}

function git_relative_last_commit {
    git -C "${1:-.}" log -1 --format=%cr --all | sed 's/minute/min/;s/hour/hr/;s/ /-/g'
}

function git_remote_update_noproxy {
    git -C "${1:-.}" remote -v update
}

function git_remote_update_proxy {
    torsocks git -C "${1:-.}" remote -v update
}

function git_remotes {
    local rmt

    rmt="$(git -C "${1:-.}" remote -v)"
    [ "$rmt" ] && printf '%s\n' "$rmt"
}

function git_remove {
    git -C "${1:-.}" rm -r --cached "$2"  ## $2 is pattern
}

function git_reset_hard {
    git -C "${1:-.}" reset --hard "$2"  ## $2 is commit hash
}

function git_reset_mixed {
    git -C "${1:-.}" reset --mixed "$2"  ## $2 is commit hash
}

function git_reset_soft {
    git -C "${1:-.}" reset --soft "$2"  ## $2 is commit hash
}

function git_reset_temp {
    ## this reverts to a commit hash in form of a temporary branch
    ## named 'HEAD detached at HASH' and switches to it.
    ## The branch will be automatically deleted after switching back to master [or any other branch !]

    git -C "${1:-.}" checkout "$2"  ## $2 is commit hash
}

function git_restore_all {
    git -C "${1:-.}" restore .
    ## PREVIOUSLY: git -C "${1:-.}" checkout -- '*'  ## NOTE do NOT remove ''
}

function git_restore_specific_or_pattern {
    git -C "${1:-.}" restore "$2"  ## $2 is item/pattern
    ## PREVIOUSLY: git -C "${1:-.}" checkout -- "$2"  ## $2 is item/pattern
}

function git_source_file_from_a_commit {
    ## Restore a specific revision of the file (as put by https://www.git-tower.com/learn/git/commands/git-restore)
    ## this function copies a file from a commit (as it was then) to the current commit
    ## this is useful when we know a time when a file worked well
    ## and we want to have it now again in the same condition as it was in that commit

    git -C "${1:-.}" restore --source "$2" "$3"  ## $2 and $3 are commit hash and file
}

function git_status {
    local stts

    stts="$(git -C "${1:-.}" status -s)"
    [ "$stts" ] && printf '%s\n' "$stts"
}

function git_tag_create {
    git -C "${1:-.}" tag "$2"  ## $2 is tag
}

function git_tag_create_with_message {
    git -C "${1:-.}" tag -a "$2" -m "$3"  ## $2 is tag, "$3 is message"
}

function git_tag_create_with_message_for_specific_commit {
    git -C "${1:-.}" tag -a "$2" -m "$3" "$4"  ## $2 is tag, "$3 is message", "$4" is commit hash
}

function git_tag_delete_all {
    git -C "${1:-.}" tag -d "${@:2}"  ## ${@:2} is tags
}

function git_tag_delete_specific {
    git -C "${1:-.}" tag -d "$2"  ## $2 is tag
}

function git_tag_show_all {
    git -C "${1:-.}" tag
}

function git_tag_show_specific {
    git -C "${1:-.}" show "$2"  ## $2 is tag
}

function git_unstage_all {
    git -C "${1:-.}" restore --staged .
    ## PREVIOUSLY: git -C "${1:-.}" reset HEAD --
}

function git_unstage_specific_or_pattern {
    git -C "${1:-.}" restore --staged "$2"  ## $2 is item/pattern
    ## PREVIOUSLY: git -C "${1:-.}" reset HEAD -- "$2"  ## $2 is item/pattern
}
