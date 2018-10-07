#!/bin/sh

# - install depends tools
# yum -y install git
# yum -y install gcc gcc-c++ autoconf libtool automake make
#

# - clone code
# git clone https://github.com/brinkqiang/dmiconv.git
# pushd dmiconv
# git submodule update --init --recursive
#

# pushd depends_path
# libtoolize && aclocal && autoheader && autoconf && automake --add-missing
# sh configure
# popd

pushd thirdparty/libiconv/unix
sh configure
make -j1
make install
popd
rm -rf build
mkdir build
pushd build
cmake -DCMAKE_BUILD_TYPE=relwithdebinfo ..
make -j1
popd
# popd