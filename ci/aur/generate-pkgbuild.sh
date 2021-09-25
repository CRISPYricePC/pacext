#!/usr/bin/env sh

VERSION=r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)
sed "s/pkgver=/pkgver=${VERSION}/g" ./ci/aur/PKGBUILD.template > \
    ./ci/aur/PKGBUILD