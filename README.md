# build_dlib_for_android
Build dlib library with zlib&amp;libpng

#### 1. build zlib static library
The build script is `zlib_android_build.sh`, in zlib-1.3.1 root.
1. Change $NDK to your ndk path
2. You can change $API to your support android version, default is 24
3. Support abi: `armv8a\armv7a\i686\x86_64`
```shell
# build
cd zlib-1.3.1
./zlib_android_build.sh

# build success, find zlib.a in zlib-1.3.1/android directory
ll
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 aarch64
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 armv7a
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 i686
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 x86_64
```

#### 2. build libpng static library
The build script is `libpng_android_build.sh`, in libpng-1.6.44  root.
> Same steps as 1
```
cd libpng-1.6.44 
./libpng_android_build.sh

# build success, find libpng.a in libpng-1.6.44/android directory
ll
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 aarch64
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 armv7a
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 i686
drwxr-xr-x  7 steven  staff   224B Jan 24 10:03 x86_64
```

#### 3. build dlib shared library
The build script is `dlib_android_build.sh`, in dlib-19.24/dlib
```shell
# start build
cd dlib-19.24/dlib
./dlib_android_build.sh 

# maybe need wait a moment
# build success, find libdlib.so in dlib-19.24/android directory
l aarch64/lib
-rwxr-xr-x  1 steven  staff    22M Jan 24 14:57 libdlib.so
```

For example, if you want to strip a libdlib.so for the ABI arm64-v8a you just need to type into the terminal:
```
# stripping libdlib.so for arm64-v8a:
$ cd dlib-19.24/android/aarc64/lib/
$ llvm_strip --strip-unneeded libdlib.so -o libdlib_strip.so
```
`llvm_strip` path in your `NDKPath/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-strip`