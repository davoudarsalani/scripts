#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/install-jdate.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/install-jdate.sh
##    https://davoudarsalani.ir

## NOTE this script is used:
##      a. for building docker image
##      b. in action-jdate

function dl_xtract {
    mkdir -p "$temp_dir"/sources
    wget --tries=inf -O "$tar_file" "$1"  ## --tries=inf or --tries=0 for infinite retrying
                                          ## because downloading is sometimes not easy when building images
    tar -xf "$tar_file" -C "$temp_dir"/sources
    rm "$tar_file"
}

## needed because user is root when creating docker image, and non-root in GitHub Actions
(( UID > 0 )) || is_root='true'

temp_dir="$(mktemp -d /tmp/jdate_tmp_XXXXXX)"  ## NOTE a. do NOT replace -d with --directory
                                               ##         because mktemp on Alpine was seen to only accept -d
                                               ##      b. Alpine requires at least six Xs.
                                               ##         any modifications you make to the template,
                                               ##         make sure to do the same in the clean-up section in dockerfiles
tar_file="$temp_dir"/jcal_latest.tar.gz

## INSTALLING-DEPENDENCIES::START
printf 'installing dependencies\n'
for dep in automake build-essential libjalali-dev libtool; {
    [ "$(command -v "$dep")" ] && continue

    ## [CHECKING_HOST]
    if [ "$(command -v apk)" ]; then
        cmd="apk add --no-cache $dep"
    elif [ "$(command -v apt)" ]; then
        cmd="apt install -y --no-install-recommends $dep"
    fi

    [ "$is_root" == 'true' ] || cmd="sudo $cmd"
    eval "$cmd" || printf 'ERROR installing %s\n' "$dep"
}
## INSTALLING-DEPENDENCIES::END

printf 'cloning/downloading\n'
case "$1" in
    'clone-github' )
        git clone https://github.com/ashkang/jcal.git "$temp_dir" ;;
    'clone-gnu' )
        git clone https://git.savannah.gnu.org/git/jcal.git "$temp_dir" ;;
    'clone-nongnu' )
        git clone https://git.savannah.nongnu.org/git/jcal.git "$temp_dir" ;;
    'askapache' )
        dl_xtract 'http://nongnu.askapache.com/jcal/jcal-latest.tar.gz' ;;
    'gnu' )
        dl_xtract 'http://download-mirror.savannah.gnu.org/releases/jcal/jcal-latest.tar.gz' ;;
    'nongnu' )
        dl_xtract 'http://download.savannah.nongnu.org/releases/jcal/jcal-latest.tar.gz' ;;
    * )
        printf 'invalid source\n'
        exit 1 ;;
esac

printf 'installing\n'
cd "$temp_dir"/sources || exit 1  ## have to cd because absolute paths won't work
./autogen.sh
./configure
make
if [ "$is_root" == 'true' ]; then
    make install
    /sbin/ldconfig
else
    sudo make install
    sudo /sbin/ldconfig
fi
