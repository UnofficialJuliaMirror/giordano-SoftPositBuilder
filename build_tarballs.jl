# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "SoftPosit"
version = v"0.4.1"

# Collection of sources required to build SoftPosit
sources = [
    "https://gitlab.com/cerlane/SoftPosit/-/archive/$version/SoftPosit-5d7f037eef37fac2790fc51a6f53bd6dfe32c2cb.tar.gz" =>
    "303f7f9678e43d897527a0246b47cbab416a9a1fbe0ed7d3d8f1826c2093677f",
    "./patches"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/SoftPosit-*/build/Linux-x86_64-GCC/
patch -p1 < $WORKSPACE/srcdir/makefile.patch
if [[ "${target}" == *darwin* ]]; then
    make SLIB=".dylib" julia
elif [[ "${target}" == *mingw* ]]; then
    make SLIB=".dll" julia
else
    make julia
fi
mkdir -p $prefix/lib
cp softposit.* $prefix/lib/.
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc),
    FreeBSD(:x86_64),
    MacOS(:x86_64),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "softposit", :SoftPositPath)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

