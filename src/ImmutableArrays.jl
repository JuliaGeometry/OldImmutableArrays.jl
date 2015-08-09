VERSION >= v"0.4.0-dev+6521" && __precompile__(true)

module ImmutableArrays

include("generate_arrays.jl")
generate_arrays(4)

export Vector1,   Vector2,   Vector3,   Vector4,
       Matrix1x1, Matrix1x2, Matrix1x3, Matrix1x4,
       Matrix2x1, Matrix2x2, Matrix2x3, Matrix2x4,
       Matrix3x1, Matrix3x2, Matrix3x3, Matrix3x4,
       Matrix4x1, Matrix4x2, Matrix4x3, Matrix4x4
end
