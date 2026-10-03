#!/bin/bash
set -e # Yeh line ensure karegi ki agar error aaye toh script wahi ruk jaye

ARCH=$1
API=21

# GitHub Actions ka standard NDK path
NDK=$ANDROID_NDK_HOME 
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

if [ "$ARCH" = "arm64-v8a" ]; then
    TARGET="aarch64-linux-android"
    CPU="armv8-a"
    EXTRA_CFLAGS="-Os -fPIC" # Android ke liye zaroori flag
elif [ "$ARCH" = "armeabi-v7a" ]; then
    TARGET="armv7a-linux-androideabi"
    CPU="armv7-a"
    EXTRA_CFLAGS="-Os -fPIC"
else
    echo "Architecture not supported"
    exit 1
fi

# Modern NDK tools manually define karna zaroori hai
CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
AR="$TOOLCHAIN/bin/llvm-ar"
NM="$TOOLCHAIN/bin/llvm-nm"
STRIP="$TOOLCHAIN/bin/llvm-strip"

echo "Building FFmpeg for $ARCH..."

./configure \
    --target-os=android \
    --architecture=$ARCH \
    --cpu=$CPU \
    --enable-cross-compile \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$AR \
    --nm=$NM \
    --strip=$STRIP \
    --sysroot=$TOOLCHAIN/sysroot \
    --extra-cflags="$EXTRA_CFLAGS" \
    --disable-everything \
    --disable-static \
    --enable-shared \
    --disable-doc \
    --disable-programs \
    --disable-avdevice \
    --disable-swscale \
    --disable-postproc \
    --disable-network \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-decoder=aac,aac_latm,alac,flac,mp3,mp3float,opus,vorbis,pcm_s16le,pcm_s24le \
    --enable-demuxer=aac,flac,mp3,ogg,wav,mov,m4a \
    --enable-parser=aac,flac,mpegaudio,opus,vorbis \
    --enable-protocol=file \
    --enable-small \
    --prefix=../output/$ARCH || { echo "Configure failed! Checking config.log..."; cat ffbuild/config.log; exit 1; }

make clean
make -j$(nproc)
make install

echo "Build complete for $ARCH!"
