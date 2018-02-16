# L-BFGS-B-Builder

[![Build Status](https://travis-ci.org/Gnimuc/L-BFGS-B-Builder.svg?branch=master)](https://travis-ci.org/Gnimuc/L-BFGS-B-Builder)

This repository serves as a shared library builder for [L-BFGS-B Nonlinear Optimization Code](http://users.iems.northwestern.edu/~nocedal/lbfgsb.html).
It will automatically configure and build binaries via [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) and [Travis CI](https://travis-ci.org).
It will deploy those binary artifacts to [GitHub releases](https://github.com/Gnimuc/L-BFGS-B-Builder/releases)
whenever a new version is tagged. Note that, only the code in this repo is licensed under MIT, those binaries
are released under BSD-3-Clause license.
