#!/bin/bash
export ANDROID_ROOT=/Users/steven/Library/Android/sdk
export NDK=$ANDROID_ROOT/ndk/21.4.7075529
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
export SYSROOT=$TOOLCHAIN/sysroot
export CFLAGS="-fPIC"
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib

CMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake
API=24

function build_abi() {
      arg1=$1
      if [ $arg1 = "armv7a" ]; then
            export TARGET=$arg1-linux-androideabi
            ABI=armeabi-v7a
      elif [ $arg1 = "aarch64" ]; then
            export TARGET=$arg1-linux-android
            ABI=arm64-v8a
      elif [ $arg1 = "i686" ]; then
            export TARGET=$arg1-linux-android
            ABI=x86
      elif [ $arg1 = "x86_64" ]; then
            export TARGET=$arg1-linux-android
            ABI=x86_64
      else
            echo "Unsupported ABI: $arg1"
            exit 1
      fi

      export CC=$TOOLCHAIN/bin/$TARGET$API-clang
      export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++

      LIBPNG=~/Downloads/Source/libpng-1.6.44/android/$arg1
      LIBZLIB=~/Downloads/Source/zlib-1.3.1/android/$arg1
      png_static=$LIBPNG/static/libpng.a
      zlib_static=$LIBZLIB/static/libz.a

      current_dir=$(pwd)                   # 获取当前目录的绝对路径
      parent_dir=$(dirname "$current_dir") # 获取上一级目录
      INSTALL_DIR=$parent_dir/android/$arg1

      rm -rf build
      mkdir -p build
      cmake -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_CXX_FLAGS=-std=c++11 -frtti -fexceptions \
            -DANDROID_ABI=$ABI \
            -DANDROID_PLATFORM=android-$API \
            -DANDROID_STL=c++_shared \
            -DANDROID_CPP_FEATURES=rtti exceptions \
            -DDLIB_USE_CUDA=OFF \
            -DPNG_INCLUDE_DIR=$LIBPNG/include \
            -DPNG_LIBRARIES=$png_static \
            -DZLIB_INCLUDE_DIR=$LIBZLIB/include \
            -DZLIB_LIBRARIES=$zlib_static \
            -DCMAKE_FIND_DEBUG_MODE=OFF \
            -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -S $(pwd) \
            -B $(pwd)/build

      cmake --build ./build --target install
}

# suppported ABI: aarch64 arm i686 x86_64
ABI_LIST=(aarch64 armv7a i686 x86_64)
# build for each ABI
for ABI in ${ABI_LIST[@]}; do
    build_abi $ABI
done