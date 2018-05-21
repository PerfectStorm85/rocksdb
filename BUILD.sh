#!/bin/bash

BUILD_ARCH=`uname -m`

case $CROSS_COMPILE in
  "aarch64-linux-gnu-")
    # FIXME: not specific to Cavium ThunderX
    ARCH_FLAGS="-march=armv8-a+crc+crypto -mtune=thunderx"
    EXTRA_AMFLAGS="--host=aarch64-linux-gnu"
    ;;
  "arm-linux-gnueabihf-")
    ARCH_FLAGS="-march=armv7-a -mtune="
    EXTRA_AMFLAGS="--host=arm-linux-gnueabihf"
    ;;
  *)
    # FIXME: workaround for bzip2
    # gcc -fPIC -O2 -g -D_FILE_OFFSET_BITS=64 -march=native -mtune=native -fuse-ld=gold -c blocksort.c
    # blocksort.c: In function 'fallbackSort':
    # blocksort.c:329:1: internal compiler error: Segmentation fault
    case $BUILD_ARCH in
      "aarch64")
        ARCH_FLAGS="-march=native"
        ;;
      *)
        ARCH_FLAGS="-march=native -mtune=native"
        ;;
    esac
    EXTRA_AMFLAGS="--host=$BUILD_ARCH-linux"
    ;;
esac

# build process of rocksdbjni depends on JDK
if test "x$JAVA_HOME" == "x"; then
  case $BUILD_ARCH in
    "aarch64")
      BUILD_ARCH=arm64
      ;;
     "armv7l")
      BUILD_ARCH=armhf
      ;;
    "x86_64")
      BUILD_ARCH=amd64
      ;;
  esac
  # NOTE: OpenJDK 8 is verified to run IRI on x86_64, ARMv7-A, and Aarch64
  # while OpenJDK 10 is not.
  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-$BUILD_ARCH
fi

if test "x$DEBUG" == "x"; then
  NPROC=`getconf _NPROCESSORS_ONLN`
else
  NPROC=1
fi

set -x
make \
  CC=${CROSS_COMPILE}gcc \
  CXX=${CROSS_COMPILE}g++ \
  AR=${CROSS_COMPILE}ar \
  STRIP=${CROSS_COMPILE}strip \
  EXTRA_CFLAGS="${ARCH_FLAGS} -fuse-ld=gold" \
  EXTRA_CXXFLAGS="${ARCH_FLAGS} -static-libstdc++ -fuse-ld=gold" \
  EXTRA_LDFLAGS="-Wl,-Bsymbolic-functions -Wl,--icf=all" \
  EXTRA_AMFLAGS="${EXTRA_AMFLAGS}" \
  DEBUG_LEVEL=0 \
  rocksdbjavastatic -j${NPROC}
