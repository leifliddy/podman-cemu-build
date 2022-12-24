#!/bin/bash

set -e

cemu_dir='/root/cemu'
cemu_git_url='https://github.com/cemu-project/Cemu'

while getopts :r arg
do
    case "${arg}" in
        r) rebuild=true ;;
    esac
done

[[ $rebuild = true ]] && [[ -d $cemu_dir ]] && rm -rf $cemu_dir
[[ ! -d $cemu_dir ]] && mkdir $cemu_dir && rebuild=true

[[ $rebuild = true ]] && git clone --recursive $cemu_git_url $cemu_dir

# perform git pull
pushd $cemu_dir
git pull --recurse-submodules
popd

# remove build directory
[[ -d $cemu_dir/build ]] && rm -rf $cemu_dir/build

# build cemu
pushd $cemu_dir
cmake -S . -B build -DCMAKE_BUILD_TYPE=release -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -G Ninja
cmake --build build
popd

strip /root/cemu/bin/Cemu_release
rsync -vr --delete --exclude='.gitignore' $cemu_dir/bin/ /output/
