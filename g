#!/usr/bin/env bash
source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

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
    [ ! -d .git ] && red 'No ' && exit
}
## }}}
if_git "$1"

function if_lock_file {  ## {{{
    lock_file=.git/index.lock
    [ -f "$lock_file" ] && red '' && exit
}
## }}}
if_lock_file

function check_pattern {  ## {{{
    matches="$(find . -mindepth 1 -iname "$pattern")"   ## -maxdepth 1 is not needed here
    [ ! "$matches" ] && red 'No such pattern' && exit
}
## }}}
function if_amend_allowed {  ## {{{
    commits_ahead="$(git branch -v | \grep 'ahead' | \grep -ioP '(?<=\[).*?(?=\])' | awk '{print $2}')"
    ## previously: commits_ahead="$(git status -s | sed '1q;d' | \grep -i 'ahead' | awk '{print $NF}' | sed 's/[^0-9]//g')"
    [ ! "$commits_ahead" ] && red 'Amend not allowed' && exit
}
## }}}
function if_changes {  ## {{{
    readarray -t mod_s <<< "$(git status -s | \grep '^ M'           | awk '{print $2}' | sed 's/\/$//')"; mod_s=(   "${mod_s[@]}" )
    readarray -t del_s <<< "$(git status -s | \grep '^ D'           | awk '{print $2}' | sed 's/\/$//')"; del_s=(   "${del_s[@]}" )
    readarray -t idA_s <<< "$(git status -s | \grep '^ A'           | awk '{print $2}' | sed 's/\/$//')"; idA_s=(   "${idA_s[@]}" )
    readarray -t idR_s <<< "$(git status -s | \grep '^ R'           | awk '{print $2}' | sed 's/\/$//')"; idR_s=(   "${idR_s[@]}" )
    readarray -t std_s <<< "$(git status -s | \grep '^[MDAR] '      | awk '{print $2}' | sed 's/\/$//')"; std_s=(   "${std_s[@]}" )
    readarray -t sts_s <<< "$(git status -s | \grep '^[MDAR][MDAR]' | awk '{print $2}' | sed 's/\/$//')"; sts_s=(   "${sts_s[@]}" )
    readarray -t unt_s <<< "$(git status -s | \grep '??'            | awk '{print $2}' | sed 's/\/$//')"; unt_s=(   "${unt_s[@]}" )

    ## deconstruction (https://unix.stackexchange.com/questions/166217/using-a-for-loop-to-loop-over-multiple-arrays-in-bash)
    mod_s=${mod_s[@]}  ## <--,
    del_s=${del_s[@]}  ## <--|
    idA_s=${idA_s[@]}  ## <--|
    idR_s=${idR_s[@]}  ## <--|-- not sure if we can quote them
    std_s=${std_s[@]}  ## <--|
    sts_s=${sts_s[@]}  ## <--|
    unt_s=${unt_s[@]}  ## <--'

    master=()  ## NOTE do NOT use declare -a since declare makes master a local variable
    for array in "$mod_s" "$del_s" "$idA_s" "$idR_s" "$std_s" "$sts_s" "$unt_s"; {
        read -a array <<< "$(printf '%s\n' "$array")"
        icon="${array[0]}"
        trimmed_array="${array[@]:1}"
        for member in ${trimmed_array[@]}; {  ## NOTE do NOT change quotes
            master+=( "${icon}---${member}" )
        }
    }

    [ ! "$master" ] && green 'Sleeping ...' && exit  ## checking if array is empty. no need to [@]
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
    readarray -t branches_list <<< "$(git branch -a --color=always | \grep -v '/HEAD\s' | sort)"  ## branches
    printf '%s\n' "${branches_list[@]}"
}
## }}}

title="${0##*/}"
heading "$title"

main_items=( 'status' 'add' 'commit' 'add_commit' 'commit_amend' 'undo' 'unstage' 'log' 'push' 'edit' 'empty_commit' 'remove' 'branch' 'tag' 'revert' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    status )  ## {{{
             if_changes
             readarray -t status_items <<< "$(printf '%s\n' "${master[@]/---/' '}")"
             status_item="$(pipe_to_fzf_locally "${status_items[@]}")" && wrap_fzf_choice "$status_item" || exit 37 ;;
             ## }}}
    add )  ## {{{
          if_changes
          readarray -t add_items <<< "$(printf '%s\n%s\n%s\n' "${master[@]/---/' '}" 'pattern' 'all')"
          add_item="$(pipe_to_fzf_locally "${add_items[@]}")" && wrap_fzf_choice "$add_item" || exit 37

          case "$add_item" in
              pattern )   get_input 'Pattern' && pattern="$input"
                          if_lock_file
                          check_pattern
                          git add "$pattern" && accomplished "$pattern added" ;;
              all )       if_lock_file
                          git add -A && accomplished 'all added' ;;
              * )         if_lock_file
                          add_item="${add_item:2}"  ## JUMP_1 remove '[] ' from the beginning
                          git add "$add_item" && accomplished "$add_item added" ;;
          esac ;;
          ## }}}
    commit )  ## {{{
             if_changes
             [ ! "${std_s}" ] && red 'No staged files' && exit  ## <--,-- "${std_s[@]}" throws error:
                                                                ##    |-- line 107: [:  zero: unary operator expected
                                                                ##    '-- so we have to use either "${std_s}" or "${std_s[@]}" 2>/dev/null

             preview_setting='hidden'
             commit_items=( "open $editor" 'write here' )
             commmit_item="$(pipe_to_fzf_locally "${commit_items[@]}")" && wrap_fzf_choice "$commit_item" || exit 37

             case "$commmit_item" in
                 "open $editor" ) if_lock_file
                                  git commit && accomplished "committed in $editor" ;;
                 'write here' ) get_input 'Message' && message="$input"
                                if_lock_file
                                git commit -m "$message" && accomplished "committed, message: $message" ;;
             esac ;;
             ## }}}
    add_commit ) ## {{{
                 if_changes
                 readarray -t add_commit_items <<< "$(printf '%s\n%s\n%s\n%s\n' "${master[@]/---/' '}" 'pattern' 'all' 'all + amend')"
                 add_commit_item="$(pipe_to_fzf_locally "${add_commit_items[@]}")" && wrap_fzf_choice "$add_commit_item" || exit 37

                 case "$add_commit_item" in
                     pattern ) get_input 'Pattern' && pattern="$input"
                               check_pattern
                               get_input 'Message' && message="$input"
                               if_lock_file
                               git add "$pattern" && git commit -m "${pattern}: $message" && accomplished "$pattern added, message: ${pattern}: $message" ;;
                     all ) get_input 'Message' && message="$input"
                           if_lock_file
                           git add -A && git commit -m "MANY: $message" && accomplished "all added, message: MANY: $message" ;;
                     'all + amend' ) if_amend_allowed
                                     if_lock_file
                                     git add -A && git commit --amend && accomplished "all added, commit amended in $editor" ;;  ## -v is optional, but it shows a lot of helpful information about the changes
                     * ) get_input 'Message' && message="$input"
                         if_lock_file
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
                       "open $editor" ) if_lock_file
                                        git commit --amend && accomplished "commit amended in $editor" ;;  ## -v is optional, but it shows a lot of helpful information about the changes
                       'write here' ) get_input 'New message' && new_message="$input"
                                      if_lock_file
                                      git commit --amend -m "$new_message" && accomplished "commit amended, message: $message" ;;  ## -v is optional, but it shows a lot of helpful information about the changes
                   esac ;;
                   ## }}}
    undo )  ## {{{
           if_changes
           get_input 'File/Pattern to undo' && pattern="$input"
           if_lock_file
           check_pattern
           git checkout -- "$pattern" && accomplished "$pattern undid" ;;
           ## }}}
    unstage )  ## {{{
              if_changes
              [ ! "${std_s}" ] && red 'No staged files' && exit  ## <--,-- "${std_s[@]}" throws error:
                                                                 ##    |-- line 107: [:  zero: unary operator expected
                                                                 ##    '-- so we have to use either "${std_s}" or "${std_s[@]}" 2>/dev/null

              preview_setting='hidden'
              instage_items=( 'all' 'file/pattern' )
              unstage_item="$(pipe_to_fzf_locally "${instage_items[@]}")" && wrap_fzf_choice "$unstage_item" || exit 37

              case "$unstage_item" in
                  all ) if_lock_file
                        git reset HEAD -- && accomplished 'all unstaged' ;;  ## unstage all staged files
                  'file/pattern' ) get_input 'File/Pattern to unstage' && pattern="$input"
                                   if_lock_file
                                   check_pattern
                                   git reset HEAD -- "$pattern" && accomplished "$pattern unstaged" ;;  ## unstage a specific staged file
              esac ;;
              ## }}}
    log )  ## {{{
          IFS=$'\n'
          if_lock_file
          preview_setting='hidden'
          readarray -t log_items <<< "$(git log --graph --full-history --all --color --abbrev-commit --date=relative --pretty=format:'%Cblue%h%Creset %C(bold black)%cr%Creset%C(green)%d%Creset %s')"
          log_item="$(pipe_to_fzf_locally "${log_items[@]}")" && wrap_fzf_choice "$log_item" || exit 37 ;;
          ## }}}
    push )  ## {{{
           if [ ! "$(git remote -v)" ]; then
               red 'No remote'
           else
               if_lock_file
               torsocks git push -u origin master && accomplished 'pushed'
           fi ;;
           ## }}}
    edit )  ## {{{
           if_lock_file
           git config -e && accomplished 'edited' ;;
           ## }}}
    empty_commit )  ## commit with nothing staged {{{

                   preview_setting='hidden'
                   empty_commit_items=( "open $editor" 'write here' )
                   empty_commit_item="$(pipe_to_fzf_locally "${empty_commit_items[@]}")" && wrap_fzf_choice "$empty_commit_item" || exit 37

                   case "$empty_commit_item" in
                       "open $editor" ) if_lock_file
                                        git commit --allow-empty -n && accomplished 'committed empty' ;;
                       'write here' ) get_input 'Message' && message="$input"
                                      if_lock_file
                                      git commit --allow-empty -n -m "$message" && accomplished "committed empty, message: $message" ;;
                   esac ;;
                   ## }}}
    remove )  ## {{{
             get_input 'File/Pattern to remove from git' && pattern="$input"
             if_lock_file
             git rm -r --cached "$pattern" && accomplished "$pattern removed" ;;
             ## }}}
    branch )  ## {{{
             preview_setting='hidden'
             branch_items=( 'show branches' 'create branch' 'checkout to a branch' 'delete all branches' 'force delete all branches' 'delete a specific branch' 'force delete a specific branch' )
             branch_item="$(pipe_to_fzf_locally "${branch_items[@]}")" && wrap_fzf_choice "$branch_item" || exit 37

             case "$branch_item" in
                 'show branches' ) if_lock_file
                                   IFS=$'\n'
                                   readarray -t show_branches_items <<< "$(branches_array)"
                                   show_branches_item="$(get_branch "${show_branches_items[@]}")" && wrap_fzf_choice "$show_branches_item" && accomplished || exit 37 ;;
                 'create branch' ) get_input 'Branch to create' && new_branch="$input"
                                   if_lock_file
                                   git branch "$new_branch" && accomplished "$new_branch branch created" ;;
                 'checkout to a branch' ) if_lock_file
                                          IFS=$'\n'
                                          readarray -t cd_to_branch_items <<< "$(branches_array)"
                                          cd_to_branch_item="$(get_branch "${cd_to_branch_items[@]}")" && wrap_fzf_choice "$cd_to_branch_item" || exit 37

                                          git checkout "$cd_to_branch_item" && accomplished "$cd_to_branch_item branch checkedout to" ;;
                 'delete all branches' ) if_lock_file
                                         git branch | \grep -v 'master' | xargs git branch -d && accomplished 'all branches deleted' ;;
                 'force delete all branches' ) if_lock_file
                                               git branch | \grep -v 'master' | xargs git branch -D && accomplished 'all branches force deleted' ;;
                 'delete a specific branch' ) if_lock_file
                                              IFS=$'\n'
                                              readarray -t delete_branch_items <<< "$(branches_array)"
                                              delete_branch_item="$(get_branch "${delete_branch_items[@]}")" && wrap_fzf_choice "$delete_branch_item" || exit 37

                                              git branch -d "$delete_branch_item" && accomplished "$delete_branch_item branch deleted" ;;
                 'force delete a specific branch' ) if_lock_file
                                                    IFS=$'\n'
                                                    readarray -t force_delete_branch_items <<< "$(branches_array)"
                                                    force_delete_branch_item="$(get_branch "${force_delete_branch_items[@]}")" && wrap_fzf_choice "$force_delete_branch_item" || exit 37

                                                    git branch -D "$force_delete_branch_item" && accomplished "$force_delete_branch_item branch force deleted" ;;
             esac ;;
             ## }}}
    tag )  ## {{{
          preview_setting='hidden'
          tag_items=( 'show tags' 'show a specific tag' 'create tag' 'create tag + message' 'create tag + message for a specific commit' 'delete all tags' 'delete a specific tag')
          tag_item="$(pipe_to_fzf_locally "${tag_items[@]}")" && wrap_fzf_choice "$tag_item" || exit 37

          case "$tag_item" in
              'show tags' ) if_lock_file
                            git tag && accomplished ;;
              'show a specific tag' ) get_input 'Tag to show' && tag="$input"
                                      if_lock_file
                                      git show "$tag" && accomplished "$tag tag shown" ;;
              'create tag' ) get_input 'Tag to create' && new_tag="$input"
                             new_tag="${new_tag// /_}"
                             if_lock_file
                             git tag "$new_tag" && accomplished "$new_tag tag created" ;;
              'create tag + message' ) get_input 'Tag to create' && new_tag="$input"
                                       get_input 'Message'       && message="$input"
                                       new_tag="${new_tag// /_}"
                                       if_lock_file
                                       git tag -a "$new_tag" -m "$message" && accomplished "$new_tag tag created, message: $message" ;;
              'create tag + message for a specific commit' ) get_input 'Tag to create' && new_tag="$input"
                                                             get_input 'Message'       && message="$input"
                                                             get_input 'Commit hash'   && com_hash="$input"
                                                             new_tag="${new_tag// /_}"
                                                             if_lock_file
                                                             git tag -a "$new_tag" -m "$message" "$com_hash" && accomplished "$new_tag tag created, message: ${message}, for commit: $com_hash" ;;
              'delete all tags' ) if_lock_file
                                  git tag | xargs git tag -d && accomplished 'all tags deleted' ;;
              'delete a specific tag' ) get_input 'Tag to delete' && tag="$input"
                                        if_lock_file
                                        git tag -d "$tag" && accomplished "$tag tag deleted" ;;
          esac ;;
          ## }}}
    revert )  ## {{{
             IFS=$'\n'
             if_lock_file
             preview_setting='hidden'
             readarray -t revert_items <<< "$(git log --pretty=oneline --color --abbrev-commit --date=relative --pretty=format:'%Cblue%h%Creset %C(bold black)%cr%Creset%C(green)%d%Creset %s')"
             revert_item="$(pipe_to_fzf_locally "${revert_items[@]}")" && wrap_fzf_choice "$revert_item" || exit 37

             revert_item="$(printf '%s\n' "$revert_item" | sed 's/ .*//g')"

             get_single_input "Revert to ${revert_item}?" && revert_prompt="$single_input"
             case "$revert_prompt" in
                 y ) git checkout "$revert_item" && accomplished "$revert_item reverted to" ;;
             esac ;;
             ## }}}
esac

exit

## ╭── git reset --soft HEAD^ : remove the last one commit but keep all the staged and unstaged files as they were.
## ├── git reset --hard HEAD^ : remove the last one commit and undo also all the staged and instaged files before that. In fact it jumps back to the commit before the last one.
## ╰─────► '^' means one commit, '^^' means two commits, and so on
