using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
  BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:aarch64, :glibc),
  BinaryProvider.Linux(:armv7l, :glibc),
  BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS(),
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build L-BFGS-B
sources = [
    "http://users.iems.northwestern.edu/~nocedal/Software/Lbfgsb.3.0.tar.gz" =>
    "f5b9a1c8c30ff6bcc8df9b5d5738145f4cbe4c7eadec629220e808dcf0e54720",
]

script = raw"""
cd $WORKSPACE/srcdir
cd Lbfgsb.3.0/

cat > Makefile.patch << 'EOP'
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
EOP

patch --ignore-whitespace < Makefile.patch

make
make install
"""

products = prefix -> [
    LibraryProduct(prefix,"liblbfgsb")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "L-BFGS-B", platforms, sources, script, products)
