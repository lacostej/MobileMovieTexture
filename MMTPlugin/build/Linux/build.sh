set -e
set -x

ORIG_DIR=`pwd`

for arch in m32; do
  export arch
  pushd ${ORIG_DIR}/../../theorawrapper
  ./build_linux.sh
  popd
done

echo "Installing libs"
if [ -f m32/lib/libtheorawrapper.so ]; then
  echo "Installing lib m32"
  file m32/lib/libtheorawrapper.so
  cp -a m32/lib/libtheorawrapper.so ../../../MMTUnity/Assets/Plugins/x86/
  #cp -a m32/lib/libtheorawrapper.so ../../../MMTUnity/target/test_linux_Data/Plugins/x86/
fi
if [ -f m64/lib/libtheorawrapper.so ]; then
  echo "Installing lib m64"
  file m64/lib/libtheorawrapper.so
  cp -a m64/lib/libtheorawrapper.so ../../../MMTUnity/Assets/Plugins/x86_64/
  #cp -a m64/lib/libtheorawrapper.so ../../../MMTUnity/target/test_linux_Data/Plugins/x86_64/
fi