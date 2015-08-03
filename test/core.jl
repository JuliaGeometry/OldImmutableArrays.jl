using ImmutableArrays
using Base.Test

typealias Vec2d Vector2{Float64}
typealias Vec3d Vector3{Float64}
typealias Vec4d Vector4{Float64}
typealias Vec3f Vector3{Float32}

v1 = Vec3d(1.0,2.0,3.0)
v2 = Vec3d(6.0,5.0,4.0)

# indexing
@test v1[1] == 1.0
@test v1[2] == 2.0
@test v1[3] == 3.0
@test_throws BoundsError v1[-1]
@test_throws BoundsError v1[0]
@test_throws BoundsError v1[4]

# negation
@test -v1 == Vec3d(-1.0,-2.0,-3.0)
@test isa(-v1,Vec3d)

# addition
@test v1+v2 == Vec3d(7.0,7.0,7.0)

# subtraction
@test v2-v1 == Vec3d(5.0,3.0,1.0)

# multiplication
@test v1.*v2 == Vec3d(6.0,10.0,12.0)

# division
@test v1 ./ v1 == Vec3d(1.0,1.0,1.0)

# scalar operations
@test 1.0 + v1 == Vec3d(2.0,3.0,4.0)
@test 1.0 .+ v1 == Vec3d(2.0,3.0,4.0)
@test v1 + 1.0 == Vec3d(2.0,3.0,4.0)
@test v1 .+ 1.0 == Vec3d(2.0,3.0,4.0)
@test 1 + v1 == Vec3d(2.0,3.0,4.0)
@test 1 .+ v1 == Vec3d(2.0,3.0,4.0)
@test v1 + 1 == Vec3d(2.0,3.0,4.0)
@test v1 .+ 1 == Vec3d(2.0,3.0,4.0)

@test v1 - 1.0 == Vec3d(0.0,1.0,2.0)
@test v1 .- 1.0 == Vec3d(0.0,1.0,2.0)
@test 1.0 - v1 == Vec3d(0.0,-1.0,-2.0)
@test 1.0 .- v1 == Vec3d(0.0,-1.0,-2.0)
@test v1 - 1 == Vec3d(0.0,1.0,2.0)
@test v1 .- 1 == Vec3d(0.0,1.0,2.0)
@test 1 - v1 == Vec3d(0.0,-1.0,-2.0)
@test 1 .- v1 == Vec3d(0.0,-1.0,-2.0)

@test 2.0 * v1 == Vec3d(2.0,4.0,6.0)
@test 2.0 .* v1 == Vec3d(2.0,4.0,6.0)
@test v1 * 2.0 == Vec3d(2.0,4.0,6.0)
@test v1 .* 2.0 == Vec3d(2.0,4.0,6.0)
@test 2 * v1 == Vec3d(2.0,4.0,6.0)
@test 2 .* v1 == Vec3d(2.0,4.0,6.0)
@test v1 * 2 == Vec3d(2.0,4.0,6.0)
@test v1 .* 2 == Vec3d(2.0,4.0,6.0)

@test v1 / 2.0 == Vec3d(0.5,1.0,1.5)
@test v1 ./ 2.0 == Vec3d(0.5,1.0,1.5)
@test v1 / 2 == Vec3d(0.5,1.0,1.5)
@test v1 ./ 2 == Vec3d(0.5,1.0,1.5)

@test 12.0 ./ v1 == Vec3d(12.0,6.0,4.0)
@test 12 ./ v1 == Vec3d(12.0,6.0,4.0)

@test v1.^2 == Vec3d(1.0,4.0,9.0)
@test v1.^2.0 == Vec3d(1.0,4.0,9.0)
@test 2.0.^v1 == Vec3d(2.0,4.0,8.0)
@test 2.^v1 == Vec3d(2.0,4.0,8.0)

# vector norm
@test norm(Vec3d(1.0,2.0,2.0)) == 3.0

# cross product
@test cross(v1,v2) == Vec3d(-7.0,14.0,-7.0)
@test isa(cross(v1,v2),Vec3d)
x = unit(Vec2d,1)
y = unit(Vec2d,2)
@test cross(x,y) == 1.0
@test cross(y,x) == -1.0

# basis vectors
e1 = unit(Vec4d,1)
e2 = unit(Vec4d,2)
e3 = unit(Vec4d,3)
e4 = unit(Vec4d,4)
@test e1 == Vec4d(1.0,0.0,0.0,0.0)
@test e2 == Vec4d(0.0,1.0,0.0,0.0)
@test e3 == Vec4d(0.0,0.0,1.0,0.0)
@test e4 == Vec4d(0.0,0.0,0.0,1.0)

# type conversion
@test isa(convert(Vec3f,v1),Vec3f)
@test Vector3([1.0,2.0,3.0]) == v1
@test convert(Vec3d,[1.0,2.0,3.0]) == v1
@test isa(convert(Vector{Float64},v1),Vector{Float64})
@test convert(Vector{Float64},v1) == [1.0,2.0,3.0]


# matrix operations

typealias Mat1d Matrix1x1{Float64}
typealias Mat2d Matrix2x2{Float64}
typealias Mat3d Matrix3x3{Float64}
typealias Mat4d Matrix4x4{Float64}


@test zero(Mat2d) == Mat2d(Vec2d(0.0,0.0),Vec2d(0.0,0.0))

v = Vec4d(1.0,2.0,3.0,4.0)
r = row(v)
c = column(v)

@test c*r == Mat4d(Vec4d(1.0,2.0,3.0,4.0),
                     Vec4d(2.0,4.0,6.0,8.0),
                     Vec4d(3.0,6.0,9.0,12.0),
                     Vec4d(4.0,8.0,12.0,16.0))
@test r*c == Matrix1x1(30.0)
@test r' == c
@test c' == r
@test row(r,1) == v
@test column(c,1) == v
@test row(r+c',1) == 2*v
@test sum(r) == sum(v)
@test prod(c) == prod(v)
@test eye(Mat3d) == Mat3d(Vec3d(1.0,0.0,0.0),Vec3d(0.0,1.0,0.0),Vec3d(0.0,0.0,1.0))
@test v*eye(Mat4d)*v == 30.0
@test -r == -1.0*r
@test diag(diagm(v)) == v

# type conversion
@test isa(convert(Matrix1x4{Float32},r),Matrix1x4{Float32})
jm = rand(4,4)
im = Matrix4x4(jm)
@test isa(im,Mat4d)
@test jm == im
im = convert(Mat4d,jm)
@test isa(im,Mat4d)
@test jm == im
jm2 = convert(Array{Float64,2},im)
@test isa(jm2,Array{Float64,2})
@test jm == jm2
@test isa(convert(Vector2{Float32},[4.;5.]).e1, Float32)

# Issue #44
let
    A = Matrix2x2(eye(2))
    @test isa(A^0, Matrix2x2)
    @test isa(A^1, Matrix2x2)
    @test isa(A^2, Matrix2x2)
end
