#!/bin/bash
export NDK=~/Library/Android/sdk/ndk/21.4.7075529
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
export SYSROOT=$TOOLCHAIN/sysroot
export CFLAGS="--sysroot=$SYSROOT -fPIC"
export PATH=$TOOLCHAIN/bin:$PATH


# start building
function build_abi()
{
    # 获取第一个参数
    arg1=$1
    # 设置 API 版本
    API=24

    # 根据参数设置 build_abi
    if [ "$arg1" = "armv7a" ]; then
        export TARGET=$arg1-linux-androideabi
    else
        export TARGET=$arg1-linux-android
        # export CHOST=$arg1-linux-android
    fi
    
    lib_dir=$(pwd)/android/$arg1

    export CHOST=llvm
    # 设置环境变量
    export CC=$TOOLCHAIN/bin/$TARGET$API-clang
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++

    # 清理并构建
    make distclean
    ./configure --prefix=$lib_dir
    make -j4 && make install

    # 移动库文件到shared static目录
    static_dir=$lib_dir/static
    shared_dir=$lib_dir/shared
    mkdir -p $shared_dir
    mkdir -p $static_dir
    cp -v $lib_dir/lib/*.a $static_dir
    cp -v $lib_dir/lib/*.so* $shared_dir
}

suppported ABI: aarch64 arm i686 x86_64
ABI_LIST=(aarch64 armv7a i686 x86_64)
build for each ABI
for ABI in ${ABI_LIST[@]}; do
    build_abi $ABI
done