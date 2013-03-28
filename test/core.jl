using ImmutableArrays

typealias Vec3d Vector3{Float64}

v1 = Vec3d(1.0,2.0,3.0)
v2 = Vec3d(6.0,5.0,4.0)

# indexing
@assert v1[1] == 1.0
@assert v1[2] == 2.0
@assert v1[3] == 3.0
@assert try v1[-1]; false; catch e; isa(e,BoundsError); end
@assert try v1[0];  false; catch e; isa(e,BoundsError); end
@assert try v1[4];  false; catch e; isa(e,BoundsError); end

# negation
@assert -v1 == Vec3d(-1.0,-2.0,-3.0)
@assert isa(-v1,Vec3d)

# addition
@assert v1+v2 == Vec3d(7.0,7.0,7.0)

# subtraction
@assert v2-v1 == Vec3d(5.0,3.0,1.0)

# multiplication
@assert v1.*v2 == Vec3d(6.0,10.0,12.0)

# division
@assert v1 ./ v1 == Vec3d(1.0,1.0,1.0)

# scalar operations
@assert 1.0 + v1 == Vec3d(2.0,3.0,4.0)
@assert v1 + 1.0 == Vec3d(2.0,3.0,4.0)
@assert 1 + v1 == Vec3d(2.0,3.0,4.0)
@assert v1 + 1 == Vec3d(2.0,3.0,4.0)

@assert v1 - 1.0 == Vec3d(0.0,1.0,2.0)
@assert 1.0 - v1 == Vec3d(0.0,-1.0,-2.0)
@assert v1 - 1 == Vec3d(0.0,1.0,2.0)
@assert 1 - v1 == Vec3d(0.0,-1.0,-2.0)

@assert 2.0 * v1 == Vec3d(2.0,4.0,6.0)
@assert v1 * 2.0 == Vec3d(2.0,4.0,6.0)
@assert 2 * v1 == Vec3d(2.0,4.0,6.0)
@assert v1 * 2 == Vec3d(2.0,4.0,6.0)

@assert v1 / 2.0 == Vec3d(0.5,1.0,1.5)
@assert v1 ./ 2.0 == Vec3d(0.5,1.0,1.5)
@assert v1 / 2 == Vec3d(0.5,1.0,1.5)
@assert v1 ./ 2 == Vec3d(0.5,1.0,1.5)

@assert 12.0 ./ v1 == Vec3d(12.0,6.0,4.0)
@assert 12 ./ v1 == Vec3d(12.0,6.0,4.0)

@assert v1.^2 == Vec3d(1.0,4.0,9.0)
@assert v1.^2.0 == Vec3d(1.0,4.0,9.0)
@assert 2.0.^v1 == Vec3d(2.0,4.0,8.0)
@assert 2.^v1 == Vec3d(2.0,4.0,8.0)

# vector norm
@assert norm(Vec3d(1.0,2.0,2.0)) == 3.0
