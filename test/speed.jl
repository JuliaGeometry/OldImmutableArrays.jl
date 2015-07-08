using ImmutableArrays

function ratio(f::Function, a1, a2, b1, b2, iters::Integer)
    if f(a1, a2) != f(b1, b2)
        return string("result mismatch:\n", f(a1, a2), "\n--- vs. ---\n", f(b1, b2))
    end
    tic()
    for i = 1:iters
        f(a1, a2)
    end
    atime = toq()
    tic()
    for i = 1:iters
        f(b1, b2)
    end
    btime = toq()
    return btime / atime
end
ratio(f::Function, a1, a2, b1, b2) = ratio(f, a1, a2, b1, b2, 1000000)
mat4ratio(f::Function, m1, m2) = ratio(f, m1, m2, Matrix4x4(m1), Matrix4x4(m2))

A = rand(4,4)
B = rand(4,4)

println("ImmutableArray operation speed relative to native Julia arrays:")
println("+ ", mat4ratio(+,A,B))
println("* ", mat4ratio(*,A,B))
