#!/bin/bash
set -e 

ABI=$1
API=21

NDK=$ANDROID_NDK_HOME 
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
EXTRA_CONFIG=""
CPU_FLAG=""

if [ "$ABI" = "arm64-v8a" ]; then
    FFMPEG_ARCH="aarch64"
    TARGET="aarch64-linux-android"
    CPU_FLAG="--cpu=armv8-a"
    EXTRA_CFLAGS="-Os -fPIC"
elif [ "$ABI" = "armeabi-v7a" ]; then
    FFMPEG_ARCH="arm"
    TARGET="armv7a-linux-androideabi"
    CPU_FLAG="--cpu=armv7-a"
    EXTRA_CFLAGS="-Os -fPIC"
elif [ "$ABI" = "x86_64" ]; then
    FFMPEG_ARCH="x86_64"
    TARGET="x86_64-linux-android"
    EXTRA_CFLAGS="-Os -fPIC"
    EXTRA_CONFIG="--disable-asm"
elif [ "$ABI" = "x86" ]; then
    FFMPEG_ARCH="x86"
    TARGET="i686-linux-android"
    EXTRA_CFLAGS="-Os -fPIC"
    EXTRA_CONFIG="--disable-asm"
else
    echo "ABI not supported"
    exit 1
fi

CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
AR="$TOOLCHAIN/bin/llvm-ar"
NM="$TOOLCHAIN/bin/llvm-nm"
STRIP="$TOOLCHAIN/bin/llvm-strip"

echo "Building FFmpeg for $ABI ($FFMPEG_ARCH)..."

./configure \
    --target-os=android \
    --arch=$FFMPEG_ARCH \
    $CPU_FLAG \
    --enable-cross-compile \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$AR \
    --nm=$NM \
    --strip=$STRIP \
    --sysroot=$TOOLCHAIN/sysroot \
    --extra-cflags="$EXTRA_CFLAGS" \
    $EXTRA_CONFIG \
    --disable-everything \
    --disable-static \
    --enable-shared \
    --disable-doc \
    --disable-programs \
    --disable-avdevice \
    --disable-swscale \
    --disable-postproc \
    --disable-network \
    --disable-hwaccels \
    --disable-vulkan \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-decoder=aac,aac_latm,alac,flac,mp3,mp3float,opus,vorbis,pcm_s16le,pcm_s24le \
    --enable-demuxer=aac,flac,mp3,ogg,wav,mov,m4a \
    --enable-parser=aac,flac,mpegaudio,opus,vorbis \
    --enable-protocol=file \
    --enable-small \
    --prefix=../output/$ABI || { echo "Configure failed!"; cat ffbuild/config.log; exit 1; }

make clean
make -j$(nproc)
make install

echo "Build complete for $ABI!"
