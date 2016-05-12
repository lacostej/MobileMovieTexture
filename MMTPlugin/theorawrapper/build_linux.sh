#!/bin/bash
#
# poor's man Makefile...
#
set -e

# we build shallow static versions of the ogg, oggz and theora libraries, with only the stuff we need for decoding
# and merge all that into with our theorawrapper lib.
#
# Note: I gave up trying to build, not only the resuling lib was too large, but the 64 bits
# version kept failing (maybe due to incompatible build settings)
#
# For the build to pass, you will need to have a few things set up properly, including
# build tooling: gcc-multilib g++-multilib lib32gcc-4.8-dev
# openGL dependencies: e.g. libgl1-mesa-dev mesa-common-dev
#
# also was missing on my machine
# sudo ln -s /usr/lib/x86_64-linux-gnu/mesa/libGL.so.1 /usr/lib/x86_64-linux-gnu/libGL.so
# sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
#
# this script expects the arch environment variable to be set
#

if [[ "$arch" -eq "m32" ]]; then
  echo "Building for 32 bits"
elif [[ "$arch" -eq "m32" ]]; then
  echo "Building for 64 bits"
else
  echo "Invalid arch: $arch"
  exit -1
fi

# 0. check and prepare the locations
ORIG_DIR=../build/Linux
if [ ! -d $ORIG_DIR ]; then
  echo "ERROR: Build directory not found"
  exit -1
fi

ORIG_DIR=`(cd $ORIG_DIR; pwd)`
PREFIX_DIR="${ORIG_DIR}/$arch"
LIB_DIR=${PREFIX_DIR}/lib/

rm -rf "$PREFIX_DIR"

mkdir -p ${LIB_DIR}

# 1. build and deploy libogg 'reduced'
cd ../ogg
if [ ! -f include/ogg/config_types.h ]; then
  sh ./autogen.sh
fi
rm -f *.o src/*.o
export CFLAGS="-$arch -fPIC -fvisibility=hidden"
gcc $CFLAGS -Iinclude -c  \
  src/bitwise.c \
  src/framing.c
ar rcs ${LIB_DIR}/libogg.a *.o
#gcc $CFLAGS -shared -o ${LIB_DIR}/libogg.so *.o

# 2. build and deploy liboggz 'reduced'
cd ../oggz
rm -f *.o src/liboggz/*.o
if [ ! -f src/linux/config.h ]; then
  sh ./autogen.sh
  # for build to work,
  # 1. package has been fetched from original source (see oggz/README.md)
  # 2. libogg built from that checkout (following instructions)
  # 3.  sh ./configure --prefix="${PREFIX_DIR}" --with-ogg="${PREFIX_DIR}"
  # 4. config.h copied under new linux/ directory
fi
export CFLAGS="-$arch -fPIC -fvisibility=hidden"
gcc $CFLAGS -I../ogg/include -Iinclude -I. -Ilinux -c  \
  src/liboggz/dirac.c \
  src/liboggz/metric_internal.c \
  src/liboggz/oggz.c \
  src/liboggz/oggz_auto.c \
  src/liboggz/oggz_comments.c \
  src/liboggz/oggz_dlist.c \
  src/liboggz/oggz_io.c \
  src/liboggz/oggz_read.c \
  src/liboggz/oggz_seek.c \
  src/liboggz/oggz_stream.c \
  src/liboggz/oggz_table.c \
  src/liboggz/oggz_vector.c \
  src/liboggz/oggz_write.c
ar rcs ${LIB_DIR}/liboggz.a *.o
#gcc $CFLAGS -shared -o ${LIB_DIR}/liboggz.a *.o

# 3. build and deploy libtheora (dec) 'reduced'
cd ../theora
rm -f *.o lib/*.o lib/arm/*.o lib/x86/*.o
export CFLAGS="-$arch -fPIC -fvisibility=hidden -msse3 -DOC_X86_ASM"
if test x"${arch}" == xm64; then
  export CFLAGS="${CFLAGS} -DOC_X86_64_ASM"
fi
gcc $CFLAGS  -Iinclude -I../ogg/include -c \
  lib/apiwrapper.c \
  lib/bitpack.c \
  lib/decinfo.c \
  lib/decapiwrapper.c \
  lib/decode.c \
  lib/dequant.c \
  lib/fragment.c \
  lib/huffdec.c \
  lib/idct.c \
  lib/info.c \
  lib/internal.c \
  lib/quant.c \
  lib/state.c \
  lib/x86/mmxfrag.c \
  lib/x86/mmxidct.c \
  lib/x86/mmxstate.c \
  lib/x86/sse2idct.c \
  lib/x86/x86cpu.c \
  lib/x86/x86state.c

#  lib/x86/x86enc.c \
#  lib/x86/x86enquant.c \
#  lib/x86/sse2encfrag.c \
#  lib/x86/mmxencfrag.c \
#  lib/x86/mmxfdct.c
#  lib/encode.c

ar rcs ${LIB_DIR}/libtheora.a *.o
#gcc $CFLAGS -shared -o ${LIB_DIR}/libtheora.so *.o

# 4. build and deploy libtheorawrapper
cd ../theorawrapper
export CFLAGS="-$arch -fPIC -DTHEORAWRAPPER_EXPORTS -DSUPPORT_OPENGL -fvisibility=hidden -msse3"
g++ $CFLAGS -I../ogg/include -I../oggz/include -I../theora/include -c *.cpp 
g++ $CFLAGS -shared -o libtheorawrapper.so *.o  \
   -L${LIB_DIR} -Wl,--whole-archive,-Bstatic -l theora -l oggz -l ogg  \
   -Wl,--no-whole-archive,-Bdynamic -l GL -l pthread \
#   -Wl,-z,defs
cp *.so ${LIB_DIR}

# useful for troubleshooting
ls -la *.so
file *.so
ldd *.so