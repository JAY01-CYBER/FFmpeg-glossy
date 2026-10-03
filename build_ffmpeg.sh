#!/bin/bash
ARCH=$1
API=21 # Minimum Android API level

# GitHub Actions me ANDROID_NDK_LATEST_HOME automatic set hota hai
NDK=$ANDROID_NDK_LATEST_HOME 
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# Architecture setup
if [ "$ARCH" = "arm64-v8a" ]; then
    TARGET="aarch64-linux-android"
    CPU="armv8-a"
elif [ "$ARCH" = "armeabi-v7a" ]; then
    TARGET="armv7a-linux-androideabi"
    CPU="armv7-a"
else
    echo "Architecture not supported"
    exit 1
fi

CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"

echo "Building FFmpeg for $ARCH..."

./configure \
    --target-os=android \
    --architecture=$ARCH \
    --cpu=$CPU \
    --enable-cross-compile \
    --cc=$CC \
    --cxx=$CXX \
    --sysroot=$TOOLCHAIN/sysroot \
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
    --prefix=../output/$ARCH

make clean
make -j$(nproc)
make install

echo "Build complete for $ARCH!"
