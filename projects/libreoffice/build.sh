#!/bin/bash -eu

#shuffle CXXFLAGS -stdlib=libc++ arg into CXX as well because we use
#the CXX as the linker and need to pass -stdlib=libc++ to build
export CXX="$CXX -stdlib=libc++"
#similarly force the -fsanitize etc args in as well as pthread to get
#things to link successfully during the build
export LDFLAGS="$CFLAGS -lpthread"

cd $WORK
$SRC/libreoffice/autogen.sh --with-distro=LibreOfficeOssFuzz --with-external-tar=$SRC

#build-time rsc tool leaks a titch
export ASAN_OPTIONS="detect_leaks=0"

make fuzzers

#some minimal fonts required
cp $SRC/libreoffice/extras/source/truetype/symbol/opens___.ttf instdir/share/fonts/truetype/Liberation* $OUT
#minimal runtime requirements
mkdir $OUT/services $OUT/types
pushd instdir/program
cp *fuzzer *rc *rdb */*rdb $OUT
popd

#starting corpuses
cp $SRC/*_seed_corpus.zip $OUT
