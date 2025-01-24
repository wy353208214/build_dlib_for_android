#!/bin/bash
export NDK=~/Library/Android/sdk/ndk/21.4.7075529
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
export SYSROOT=$TOOLCHAIN/sysroot
export PATH=$TOOLCHAIN/bin:$PATH

function build_abi() {
    # 获取第一个参数
    arg1=$1
    # 设置 API 版本
    API=24
    # 根据参数设置 build_abi，非arm不要开启neon
    if [ "$arg1" = "armv7a" ]; then
        export TARGET=$arg1-linux-androideabi
        neon=-enable-arm-neon=yes
    elif [ "$arg1" = "aarch64" ]; then
        export TARGET=$arg1-linux-android
        neon=-enable-arm-neon=yes
    elif [ "$arg1" = "i686" ]; then
        export TARGET=$arg1-linux-android
        neon=""
    elif [ "$arg1" = "x86_64" ];then
        export TARGET=$arg1-linux-android
        neon=""
    else
        echo "Unsupported ABI: $arg1"
        exit 1
    fi

    # 设置环境变量
    export CC=$TOOLCHAIN/bin/$TARGET$API-clang
    export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib


    lib_dir=$(pwd)/android/$arg1
    # 清理并构建
    ZLIB_DIR=~/Downloads/Source/zlib-1.3.12/android/$arg1
    CFLAGS="--sysroot=$SYSROOT -I$ZLIB_DIR/include -fPIC"
    # 链接动态库
    # LDFLAGS="-L$ZLIB_DIR/lib"
    # 链接静态库
    LDFLAGS="-static -L$ZLIB_DIR/lib -lz"

    make distclean
    ./configure --prefix=$lib_dir --host=$TARGET --with-zlib-prefix=$ZLIB_DIR $neon CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" --disable-shared

    make -j4
    make install

    # 移动库文件到shared static目录
    static_dir=$lib_dir/static
    shared_dir=$lib_dir/shared
    mkdir -p $shared_dir
    mkdir -p $static_dir
    cp -v $lib_dir/lib/libpng16.a $static_dir/libpng.a
    cp -v $lib_dir/lib/*.so* $shared_dir
}


# suppported ABI: aarch64 arm i686 x86_64
ABI_LIST=(aarch64 armv7a i686 x86_64)
# build for each ABI
for ABI in ${ABI_LIST[@]}; do
    build_abi $ABI
done