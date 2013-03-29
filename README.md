# ImmutableArrays.jl

Statically-sized immutable vectors and matrices.


## Features

- A macro for generating vector and matrix types and methods up to
  an arbitrary dimension.
- A default instantiation of types up to dimension 4.
- Unrolled implementations of arithmetic operations 
  and mathematical functions.
- Unrolled matrix-vector and matrix-matrix multiplication.
- Conversions between vectors and row/column matrices.


## TODO

- Add a complete test suite.
- Add projective geometry.


## Status

The implementation is, in intention at least, fairly feature-complete.
However, vast amounts of the code are as yet untested. Please use caution.


## Credits

- Automatic generation of types jumpstarted via 
  [Jay Weisskopf's gist](https://gist.github.com/jayschwa/5250636).
- Feedback and testing provided by:
	- Jay Weisskopf (@jayschwa)
	- Olli Wilkman (@dronir)
