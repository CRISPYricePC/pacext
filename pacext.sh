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

usage() {
    echo "pacext - pacman extensions"
    echo " "
    echo "pacext [options] [arguments]"
    echo " "
    echo "options:"
    echo "-h, --help                    show this help"
    echo "-p, --whatprovides <file>     get info on the package that provides a given file"
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

whatprovides() {
    exec $PACMAN -Qoq "$@" | $PACMAN -Qi - | displaypackages
}

whatrequires() {
    $PACMAN -Qi "$@" | grep "Required By" | sed "s/Required By *: //g;s/  /\n/g" | $PACMAN -Qi - | displaypackages
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
    -p|--whatprovides)
        shift
        whatprovides "$@"
        ;;
    -r|--whatrequires)
        shift
        whatrequires "$@"
        ;;
    -a|--autoremove)
        shift
        autoremove "$@"
        ;;
    -k|--check-kernel)
        check-kernel
        ;;
    *)
        break
        ;;
esac
