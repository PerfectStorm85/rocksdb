#!/bin/sh

# FIXME: specify ARM64 JDK path
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

export CROSS_COMPILE=aarch64-linux-gnu-

set -x
make \
  CC=${CROSS_COMPILE}gcc \
  CXX=${CROSS_COMPILE}g++ \
  AR=${CROSS_COMPILE}ar \
  STRIP=${CROSS_COMPILE}strip \
  EXTRA_CXXFLAGS="-static-libstdc++ -fuse-ld=gold" \
  EXTRA_LDFLAGS="-Wl,-Bsymbolic-functions" \
  EXTRA_AMFLAGS="--host=aarch64-linux-gnu" \
  DEBUG_LEVEL=0 \
  rocksdbjavastatic -j8
