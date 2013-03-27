# ImmutableArrays.jl

Statically-sized immutable vectors and matrices.

[![Build Status](https://travis-ci.org/twadleigh/ImmutableArrays.jl.png?branch=master)](https://travis-ci.org/twadleigh/ImmutableArrays.jl)

## Features

- A function for generating vector and matrix types and methods up to
  an arbitrary dimension.
- A default instantiation of types up to dimension 4.
- Unrolled implementations of arithmetic operations 
  and mathematical functions.
- Unrolled matrix-vector and matrix-matrix multiplication.
- Conversions between vectors and row/column matrices.


## TODO

- Add more constructors.
- Add a more complete correctness test suite.
- Add a performance benchmark test suite.
- Add projective geometry.


## Status

The implementation is, in intention at least, fairly feature-complete.
The code has been lightly tested,
sufficient to give the author some degree of confidence in its correctness, 
but be warned that it is still fairly immature.


## Credits

- Automatic generation of types jumpstarted via 
  [Jay Weisskopf's gist](https://gist.github.com/jayschwa/5250636).
- Feedback and testing provided by:
	- Jay Weisskopf (@jayschwa)
	- Olli Wilkman (@dronir)
