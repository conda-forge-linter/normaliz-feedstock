#!/bin/bash

set -e

autoreconf --install
chmod +x configure

case `uname` in
    Darwin|Linux)
        export CFLAGS="-O3 -g -fPIC $CFLAGS"
        ./configure --prefix=$PREFIX --with-e-antic=$PREFIX --with-nauty=$PREFIX --with-flint=$PREFIX --with-gmp=$PREFIX
        ;;
    MINGW*)
        export PATH="$PREFIX/Library/bin:$BUILD_PREFIX/Library/bin:$RECIPE_DIR:$PATH"
        export CC=cl_wrapper.sh
        export RANLIB=llvm-ranlib
        export AS=llvm-as
        export AR=llvm-ar
        export LD=lld-link
        export CCCL=clang-cl
        export NM=llvm-nm
        export CFLAGS="-MD -I$PREFIX/Library/include -O2"
        export LDFLAGS="$LDFLAGS -L$PREFIX/Library/lib"
        export lt_cv_deplibs_check_method=pass_all
        cp $PREFIX/Library/gmp.lib $PREFIX/Library/gmpxx.lib
        ./configure --prefix="$PREFIX/Library" --without-e-antic --with-nauty=$PREFIX --without-flint --with-gmp=$PREFIX
        ;;
esac

make -j${CPU_COUNT}
make check -j${CPU_COUNT}
make install

if [[ `uname` == MINGW* ]]; then
    PROJECT=normaliz
    LIBRARY_LIB=$PREFIX/Library/lib
    mv "${LIBRARY_LIB}/${PROJECT}.lib" "${LIBRARY_LIB}/${PROJECT}_static.lib"
    mv "${LIBRARY_LIB}/${PROJECT}.dll.lib" "${LIBRARY_LIB}/${PROJECT}.lib"
    rm $PREFIX/Library/gmpxx.lib
fi
