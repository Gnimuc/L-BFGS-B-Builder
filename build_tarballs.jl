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
    "http://users.iems.northwestern.edu/~nocedal/Software/Lbfgsb.2.1.tar.gz" =>
    "343b566b5b3bd3d762bfafcebf873a1c3285ef49e66711c6853098ab6ec43c62",
]

script = raw"""
cd $WORKSPACE/srcdir
cd Lbfgsb.2.1/

cat > Makefile.patch << 'EOP'
--- Makefile
+++ Makefile
@@ -1,21 +1,24 @@
-FC = gfortran
-
-FFLAGS = -O
-
-DRIVER1 = driver1.o
-DRIVER2 = driver2.o
-DRIVER3 = driver3.o
-
-ROUTINES = routines.o
+VERSION = 2

-all :  lbfgsb1 lbfgsb2 lbfgsb3
-
-lbfgsb1 : $(DRIVER1) $(ROUTINES)
-	$(FC) $(FFLAGS) $(DRIVER1) $(ROUTINES) -o x.lbfgsb1
-
-lbfgsb2 : $(DRIVER2) $(ROUTINES)
-	$(FC) $(FFLAGS) $(DRIVER2) $(ROUTINES) -o x.lbfgsb2
-
-lbfgsb3 : $(DRIVER3) $(ROUTINES)
-	$(FC) $(FFLAGS) $(DRIVER3) $(ROUTINES) -o x.lbfgsb3
+FC = gfortran
+FFLAGS = -O3 -fPIC -shared
+LIB_SEARCH_PATH = lib

+OS := $(shell uname)
+ifeq ($(OS), Linux)
+SHLIB_EXT := so
+else ifeq ($(OS), Darwin)
+SHLIB_EXT := dylib
+else
+SHLIB_EXT := dll
+LIB_SEARCH_PATH = bin
+endif
+
+lbfgsb : routines.f
+	$(FC) $(FFLAGS) routines.f -o liblbfgsb-$(VERSION).$(SHLIB_EXT)
+
+all : lbfgsb
+
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
