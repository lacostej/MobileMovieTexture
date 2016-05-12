set -e

PREFIX_DIR=`pwd`/../../build/Linux/$arch/lib/
PREFIX_DIR=`(cd $PREFIX_DIR; pwd)`

LOCAL_CFLAGS="-DTHEORAWRAPPER_EXPORTS -DSUPPORT_OPENGL -fvisibility=hidden -g -mssse3"

if test x"${arch}" == xm32; then
	LOCAL_CFLAGS="$LOCAL_CFLAGS -DOC_X86_ASM"
fi
if test x"${arch}" == xm64; then
	LOCAL_CFLAGS="$LOCAL_CFLAGS -DOC_X86_ASM -DOC_X86_64_ASM"
fi
CFLAGS="$CFLAGS -$arch -fPIC -Wall -O3 $LOCAL_CFLAGS"

echo "CFLAGS $CFLAGS"

rm -f *.o 
g++ $CFLAGS -I.. -g -c *.cpp
g++ $CFLAGS -g -o test_theorawrapper *.o -L${PREFIX_DIR} -l theorawrapper

# requires libc6-dbg
#ls -la *.so
#file *.so
LD_LIBRARY_PATH=$PREFIX_DIR ldd test_theorawrapper
#cp *.so ${PREFIX_DIR}/lib/

echo "Testing with ogv files"
for a in `ls *.ogv | head -1`; do
  LD_LIBRARY_PATH=$PREFIX_DIR valgrind --partial-loads-ok=yes --leak-check=full --track-origins=yes ./test_theorawrapper $a
  LD_LIBRARY_PATH=$PREFIX_DIR valgrind --tool=helgrind ./test_theorawrapper $a
  LD_LIBRARY_PATH=$PREFIX_DIR valgrind --tool=drd ./test_theorawrapper $a
done