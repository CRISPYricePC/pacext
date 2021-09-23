#!/usr/bin/env sh

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
    echo "-a, --autoremove [package]    remove unused dependencies"
    echo "-w, --whatprovides <file>     get info on the package that provides a given file"
    exit 0
}

whatprovides() {
    exec $PACMAN -Qoq "$@" | $PACMAN -Qi -
}

autoremove() {
    exec $PACMAN -Qdtq $@ | $ROOT_CMD $PACMAN -Rs -
}

case "$1" in
    -h|--help)
        usage
        ;;
    -w|--whatprovides)
        shift
        whatprovides "$@"
        ;;
    -a|--autoremove)
        shift
        autoremove "$@"
        ;;
    *)
        break
        ;;
esac
