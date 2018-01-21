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
cd ${WORKSPACE}/srcdir
cd Lbfgsb.2.1/
gfortran -O3 -fPIC -shared routines.f -o ${DESTDIR}/liblbfgsb-2.so
"""

products = prefix -> [
    LibraryProduct(prefix,"liblbfgsb")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "L-BFGS-B", platforms, sources, script, products)
