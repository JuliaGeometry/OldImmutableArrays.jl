using Vecs

v1 = Vec3d(1.0,2.0,3.0)
v2 = Vec3d(6.0,5.0,4.0)

# addition
@assert v1+v2 == Vec3d(7.0,7.0,7.0)

# multiplication
@assert v1.*v2 == Vec3d(6.0,10.0,12.0)
