#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/tmux-statusline.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/tmux-statusline.sh
##    https://davoudarsalani.ir

case "$1" in
    if_kaddy )
        ## NOTE do NOT "$HOME" -> ~
        \grep -qi "$HOME"/kaddy <<< "$2" && printf 'KADDY \n' ;;
    info )
        if [ "$2" == ~ ] || [ "$2" == ~/kaddy ]; then  ## OR JUMP_1
            printf '%s\n' '--'
            exit
        fi

        source ~/main/scripts/gb-calculation.sh

        size="$(du -bs "$2" | awk '{print $1}')"
        size="$(convert_byte "$size")"

        directories_count="$(wc -l < <(find "$2" -mindepth 1 -maxdepth 1 -type d))"
        files_count="$(wc -l < <(find "$2" -mindepth 1 -maxdepth 1 -type f))"
        links_count="$(wc -l < <(find "$2" -mindepth 1 -maxdepth 1 -type l))"
        (( links_count > 0 )) && links_count=" L:${links_count}" || links_count=''

        printf '%s %s %s%s\n' "$size" "$directories_count" "$files_count" "$links_count" ;;
    git )
        source ~/main/scripts/gb-git.sh

        [ "$(if_git "$2")" == 'false' ] && exit

        alert_sign='🔸'  ## 🔸🔴

        hash_head="$(git_hash_head "$2")"
        relative_head="$(git_relative_head "$2")"

        hash_last_commit="$(git_hash_last_commit "$2")"
        [ "$hash_head" == "$hash_last_commit" ] || {
            relative_last_commit="$(git_relative_last_commit "$2")"
            is_head_detached="${alert_sign}${hash_last_commit}(${relative_last_commit})"
        }

        commits_count=" C:$(git_commits_count "$2")"  ## Ⓒ

        stts="$(git_status "$2")"
        [ "$stts" ] && {
            if_status=" $alert_sign"
            mod_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^ M'))"
            del_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^ D'))"
            ren_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^ R'))"
            add_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^ A'))"
            unt_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^??'))"
            upd_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^UU'))"  ## updated but unmerged
            sta_count="$(wc -l   < <(printf '%s\n' "$stts" | \grep '^[MDAR] '))"
            sta_m_count="$(wc -l < <(printf '%s\n' "$stts" | \grep '^[MDAR][MDAR]'))"  ## staged but modified

            (( mod_count   > 0 )) && mod=" M:$mod_count"   ## 
            (( del_count   > 0 )) && del=" D:$del_count"   ## 
            (( ren_count   > 0 )) && ren=" R:$ren_count"   ## Ⓡ
            (( add_count   > 0 )) && add=" A:$add_count"   ## 
            (( unt_count   > 0 )) && unt=" U:$unt_count"   ## 
            (( upd_count   > 0 )) && upd=" UU:$upd_count"  ## 
            (( sta_count   > 0 )) && sta=" S:$sta_count"   ## 
            (( sta_m_count > 0 )) && sta_m=" SM:$sta_m_count"  ## 
        }

        commits_ahead="$(git_commits_ahead "$2")"
        (( commits_ahead > 0 )) && commits_ahead=" A:${commits_ahead}" || commits_ahead=''  ## Ⓐ

        current_branch="$(git_current_branch "$2")"
        branches_count="$(wc -l < <(git_branches_exclude_remote "$2"))"
        (( branches_count > 1 )) && branch_info=" B:${current_branch}:${branches_count}"

        remotes="$(git_remotes "$2")"
        \grep -qi 'github' <<< "$remotes" && logo=' '
        [ "$remotes" ] || is_local=' LOCAL'

        printf 'H:%s:%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
            "$hash_head" \
            "$relative_head" \
            "$is_head_detached" \
            "$commits_count" \
            "$commits_ahead" \
            "$branch_info" \
            "$logo" \
            "$is_local" \
            \
            "$if_status" \
            "$mod" \
            "$del" \
            "$ren" \
            "$add" \
            "$unt" \
            "$upd" \
            "$sta" \
            "$sta_m"
        ;;
    if_dell )
        ## [CHECKING_HOST]
        [ "$HOSTNAME" == 'acer' ] || printf '%s \n' "${HOSTNAME^^}" ;;
    if_ssh )
        [ "$SSH_CONNECTION" ] && printf 'SSH \n' ;;
esac
