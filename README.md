Geometry.jl
===========

Basic geometric primitives and operations.


Current state
-------------

A type for 2D and 3D points plus some basic arithmetic.


Ambitions
---------

This library is currently little more than a stub, but may grow to include:

* the common bits for the various visualization efforts;
* representations, conversions, and operations for a variety of mathematical
and geophysical coordinate systems;
* computational geometry algorithms.

Big ideas welcome. 
Also welcome are sensible ideas about what the right scope for this
package is, versus what should be left for other dependent packages.
One thing I would like to do to bound the scope of this library is to keep 
it pure Julia.


Possible sources of inspiration
-------------------------------

* [__CGAL (Computational Geometry Algorithms Library)__](http://www.cgal.org).
Pluses: 
Fairly comprehensive. 
Algorithmically rigorous.
Minuses: 
C++ interface would probably require a C binding layer.
GPL license is more restrictive than the MIT License of
* [__Qhull__](http://www.qhull.org). 
Plus: the core has undergone years of exercise in the real world.
Minus: both the C and C++ interfaces are considered incomplete/provisional 
according to the website.
* __Matlab, Octave, R.__ Matlab and Octave, it seems, do little more than
wrap Qhull. R may have some packages that do more. Hopefully some of the
R expats in the Julia community will be able to weigh in on this.
* [__GDAL (Geospatial Data Abstraction Library)__](http://www.osgeo.org/gdal_ogr). 
For when we consider the geospatial problem. 
(Maybe best left to a downstream package.)



