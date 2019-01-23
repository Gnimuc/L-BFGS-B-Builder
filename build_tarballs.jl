# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "LBFGSB"
version = v"3.0"

# Collection of sources required to build LBFGSB
sources = [
    "http://users.iems.northwestern.edu/~nocedal/Software/Lbfgsb.3.0.tar.gz" =>
    "f5b9a1c8c30ff6bcc8df9b5d5738145f4cbe4c7eadec629220e808dcf0e54720",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd Lbfgsb.3.0/

cat > Makefile.patch << 'END'
--- Makefile
+++ Makefile
@@ -1,37 +1,30 @@
+VERSION = 3
+
 FC = gfortran
+FFLAGS = -O3 -fPIC -shared -Wall -fbounds-check -g -Wno-uninitialized

-FFLAGS = -O -Wall -fbounds-check -g -Wno-uninitialized
+LIB_SEARCH_PATH = lib

-DRIVER1_77 = driver1.f
-DRIVER2_77 = driver2.f
-DRIVER3_77 = driver3.f
-
-DRIVER1_90 = driver1.f90
-DRIVER2_90 = driver2.f90
-DRIVER3_90 = driver3.f90
+OS := $(shell uname)
+ifeq ($(OS), Linux)
+  SHLIB_EXT := so
+else ifeq ($(OS), Darwin)
+  SHLIB_EXT := dylib
+else
+  SHLIB_EXT := dll
+	LIB_SEARCH_PATH = bin
+endif

 LBFGSB  = lbfgsb.f
 LINPACK = linpack.f
 BLAS    = blas.f
 TIMER   = timer.f

-all :  lbfgsb_77_1 lbfgsb_77_2 lbfgsb_77_3 lbfgsb_90_1 lbfgsb_90_2 lbfgsb_90_3
-
-
-lbfgsb_77_1 : $(DRIVER1_77) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
-	$(FC) $(FFLAGS) $(DRIVER1_77) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o x.lbfgsb_77_1
-
-lbfgsb_77_2 : $(DRIVER2_77) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
-	$(FC) $(FFLAGS) $(DRIVER2_77) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o x.lbfgsb_77_2
-
-lbfgsb_77_3 : $(DRIVER3_77) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
-	$(FC) $(FFLAGS) $(DRIVER3_77) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o x.lbfgsb_77_3
-
-lbfgsb_90_1 : $(DRIVER1_90) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
-	$(FC) $(FFLAGS) $(DRIVER1_90) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o x.lbfgsb_90_1
+lbfgsb : $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
+	$(FC) $(FFLAGS) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o liblbfgsb-$(VERSION).$(SHLIB_EXT)

-lbfgsb_90_2 : $(DRIVER2_90) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
-	$(FC) $(FFLAGS) $(DRIVER2_90) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o x.lbfgsb_90_2
+all : lbfgsb

-lbfgsb_90_3 : $(DRIVER3_90) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER)
-	$(FC) $(FFLAGS) $(DRIVER3_90) $(LBFGSB) $(LINPACK) $(BLAS) $(TIMER) -o x.lbfgsb_90_3
+install :
+	mkdir -p $(WORKSPACE)/destdir/$(LIB_SEARCH_PATH)
+	cp -f liblbfgsb*$(SHLIB_EXT) $(WORKSPACE)/destdir/$(LIB_SEARCH_PATH)/
END

patch --ignore-whitespace < Makefile.patch

make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:powerpc64le, :glibc),
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :musl, :eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]
platform = expand_gcc_versions(platform)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "liblbfgsb", :liblbfgsb)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
