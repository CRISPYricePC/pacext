#!/usr/bin/env bash

# Pacman extensions by Ben Mitchell <bjosephmitchell@gmail.com>

# https://mit-license.org/
# Copyright © 2021 Ben Mitchell
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the “Software”), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ROOT_CMD="${ROOT_CMD:-/usr/bin/sudo}"
PACMAN="${PACMAN:-/usr/bin/pacman}"

# Force LC_ALL=C
export LC_ALL=C

usage() {
    echo "pacext - pacman extensions"
    echo " "
    echo "pacext [options] [arguments]"
    echo " "
    echo "options:"
    echo "-h, --help                    show this help"
    echo "-s, --summary                 show pacman package summary"
    echo "-p, --whatprovides <file>     get info on the package that provides a given file"
    echo "-d, --whatdepends <package>   get a list of packages that this package depends on"
    echo "-r, --whatrequires <package>  get a list of packages that depend on this package"
    echo "-a, --autoremove [package]    remove unused dependencies"
    echo "-k, --check-kernel            checks loaded kernel version against installed one"
    exit 0
}

# Displays packages as if they were searched for in pacman
displaypackages() {
    while read LINE
    do
        if [[ $LINE == *"Name"* ]]; then
            printf "\e[1m$LINE\e[0m" | sed "s/Name *: *//g"
        fi
        if [[ $LINE == *"Version"* ]]; then
            printf " \e[1;32m$LINE\e[0m" | sed "s/Version *: *//g"
        fi
        if [[ $LINE == *"Description"* ]]; then
            printf "\n    $LINE\n" | sed "s/Description *: *//g"
        fi
    done < "${1:-/dev/stdin}"
}

summary() {
    printf "Package Summary:\n"
    printf "Number of packages: %s\n" $(pacman -Qq "$@" | wc -l)
    printf "Explicitly installed packages: %s\n" $(pacman -Qeq "$@" | wc -l)
    printf "Total Storage Consumed: %s\n" \
        $($PACMAN -Qi "$@" | awk '/^Installed Size/{print $4$5}' \
            | numfmt --from=auto --suffix=B | awk 'BEGIN {sum=0} {sum=sum+$1} END {printf "%.0f\n", sum}' \
            | numfmt --to=iec-i --suffix=B)
}

whatprovides() {
    exec $PACMAN -Qoq "$@"
}

whatdepends() {
    $PACMAN -Qi "$@" | awk -F'[:]' '/^Depends/ {print $2}' | xargs -n1
}

whatrequires() {
    $PACMAN -Qi "$@" | awk -F'[:]' '/^Required/ {print $2}' | xargs -n1
}

autoremove() {
    exec $PACMAN -Qdtq $@ | $ROOT_CMD $PACMAN -Rs -
}

check-kernel() {
    KERNEL_VERSION=$(pacman -Qi linux | grep Version | sed "s/Version * : *//g;s/.arch/-arch/g")
    LOADED_VERSION=$(uname -r)

    printf "\e[1mKernel Version\e[0m : $KERNEL_VERSION\n"
    printf "\e[1mLoaded Version\e[0m : $LOADED_VERSION\n"
    printf "\e[1mMatched\e[0m        : "

    if [ $KERNEL_VERSION = $LOADED_VERSION ]
    then
        printf "\e[1;32mYes\e[0m\n"
        exit 0
    else
        printf "\e[1;31mNo\e[0m\n"
        exit 1
    fi
}

case "$1" in
    -h|--help)
        usage
        ;;
    -s|--summary)
        shift
        summary "$@"
        ;;
    -p|--whatprovides)
        shift
        whatprovides "$@" | $PACMAN -Qi - | displaypackages
        ;;
    -d|--whatdepends)
        shift
        whatdepends "$@" | $PACMAN -Qi - | displaypackages
        ;;
    -r|--whatrequires)
        shift
        whatrequires "$@" | $PACMAN -Qi - | displaypackages
        ;;
    -a|--autoremove)
        shift
        autoremove "$@"
        ;;
    -k|--check-kernel)
        check-kernel
        ;;
    *)
        printf "\e[1;31mInvalid Command\e[0m: $1\n\n"
        usage
        ;;
esac
