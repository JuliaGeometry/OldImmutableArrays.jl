# ImmutableArrays.jl

Statically-sized immutable vectors and matrices.

[![Build Status](https://travis-ci.org/twadleigh/ImmutableArrays.jl.png?branch=master)](https://travis-ci.org/twadleigh/ImmutableArrays.jl)
[![ImmutableArrays](http://pkg.julialang.org/badges/ImmutableArrays_0.2.svg)](http://pkg.julialang.org/?pkg=ImmutableArrays&ver=0.2)

## Features

- A function for generating vector and matrix types and methods up to
  an arbitrary dimension.
- A default instantiation of types up to dimension 4.
- Unrolled implementations of arithmetic operations 
  and mathematical functions.
- Unrolled matrix-vector and matrix-matrix multiplication.
- Conversions between vectors and row/column matrices.
- Conversions from AbstractArray and to Array.

## Credits

- Automatic generation of types jumpstarted via 
  [Jay Weisskopf's gist](https://gist.github.com/jayschwa/5250636).
- Travis CI integration by Jay Weisskopf (@jayschwa).
- Additional feedback and testing provided by Olli Wilkman (@dronir).
