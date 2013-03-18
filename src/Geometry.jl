module Geometry

# Distinct Types: Point, Vector, Direction
# Others: lines, rays, segments, planes, triangles, tetrahedra,
#  isorectangles, isocuboids, circles and spheres.
# Coordinate systems: Cartesian, Polar, Cylindrical, Spherical, (Projective?)

# Vector, Direction, etc, may only be meaningful in Cartesian systems.
# Maybe cartesian coords should be made canonical, with other coordinate
# systems only defined to operate on Points and only as conversions
# to/from cartesian coords. (Should projective be fundamental, too?)

# Related packages: geospatial mapping, units

# Should a point carry with it its coordinate system? (Probably not.)

# Should there be a global coordinate system? If I recall, Mathematica
# might do something like this. Probably not an ideal solution. If there
# where a way to (lexically?) scope the coordinate system, that might be 
# the best compromise between saving space by not specifying the coord
# sys on a pt-by-pt basis and leaving the coordinate system entirely in
# the user's head.


# Basic types

immutable Point2{T}
    x :: T
    y :: T
end

typealias Point2d Point2{Float64}
typealias Point2f Point2{Float32}

immutable Point3{T}
    x :: T
    y :: T
    z :: T
end

typealias Point3d Point3{Float64}
typealias Point3f Point3{Float32}

export Point2, Point2d, Point2f, Point3, Point3d, Point3f


# Basic operations

import Base.+, Base.-, Base.*, Base./

+{T}(v1::Point2{T},v2::Point2{T}) = Point2{T}(v1.x+v2.x,v1.y+v2.y)
-{T}(v1::Point2{T},v2::Point2{T}) = Point2{T}(v1.x-v2.x,v1.y-v2.y)
*{T}(s::T,v::Point2{T}) = Point2{T}(s*v.x,s*v.y)
*{T}(v::Point2{T},s::T) = Point2{T}(v.x*s,v.y*s)
/{T}(v::Point2{T},s::T) = Point2{T}(v.x/s,v.y/s)

+{T}(v1::Point3{T},v2::Point3{T}) = Point3{T}(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z)
-{T}(v1::Point3{T},v2::Point3{T}) = Point3{T}(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
*{T}(s::T,v::Point3{T}) = Point3{T}(s*v.x,s*v.y,s*v.z)
*{T}(v::Point3{T},s::T) = Point3{T}(v.x*s,v.y*s,v.z*s)
/{T}(v::Point3{T},s::T) = Point3{T}(v.x/s,v.y/s,v.z/s)


end
