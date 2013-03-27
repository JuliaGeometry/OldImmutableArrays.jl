module ImmutableArrays

importall Base

abstract ImmutableArray{T,N} <: AbstractArray{T,N}
typealias ImmutableVector{T} ImmutableArray{T,1}
typealias ImmutableMatrix{T} ImmutableArray{T,2}

# generate the vector types
for n = 2:4
    local Typ = symbol(string("Vector",n))
    local TypT = Expr(:curly, Typ, :T)

    # the body of the type definition
    local defn = :(immutable $TypT <: ImmutableVector{T} end)

    # the members of the type
    for i = 1:n
        local elt = symbol(string("e",i))
        push!(defn.args[3].args, :($elt::T))
    end

    # n-ary constructor
    local ctorn = :($Typ() = new())
    for i = 1:n
        local arg = symbol(string("a",i))
        push!(ctorn.args[1].args, arg)
        push!(ctorn.args[2].args, arg)
    end
    push!(defn.args[3].args, ctorn)

    # unary constructor
    local ctor1 = :($Typ(a) = new())
    for i = 1:n
        push!(ctor1.args[2].args, :a)
    end
    push!(defn.args[3].args, ctor1)

    # instantiate the type definition
    eval(defn)

    # some one-liners
    @eval similar{T}(::$TypT, t::DataType, dims::Dims) = Array(t, dims)
    @eval size(::$Typ) = ($n,)
    @eval zero{T}(::Type{$TypT}) = $TypT(zero(T))

    # define getindex
    local getix = :(error(BoundsError))
    for i = n:-1:1
        en = Expr(:quote,symbol(string("e",i)))
        getix = :(if ix == $i return v.($en) else $getix end)
    end
    getix = :(getindex{T}(v::$TypT, ix::Integer) = $getix)
    eval(getix)

    # higher-order functions
    # Note: these are type-constrained (f:T->T or f:TxT->T).
    # That's good enough to define the basic operations that we want
    # but maybe we can/should generalize it.
    local mp = :($TypT())
    local zp = :($TypT())
    local fl = :s
    for i = 1:n
        local en = Expr(:quote,symbol(string("e",i)))
        push!(mp.args, :(f(v.($en))))
        push!(zp.args, :(f(v1.($en),v2.($en))))
        fl = :(f($fl,v.($en)))
    end
    @eval map{T}(f,v::$TypT) = $mp
    @eval zipWith{T}(f,v1::$TypT,v2::$TypT) = $zp
    @eval fold{T}(f,s::T,v::$TypT) = $fl

    # pointwise unary operations
    @eval conj{T}(v::$TypT) = map(conj,v)

    # pointwise binary operations
    @eval  +{T}(v1::$TypT,v2::$TypT) = zipWith( +,v1,v2)
    @eval  -{T}(v1::$TypT,v2::$TypT) = zipWith( -,v1,v2)
    @eval .*{T}(v1::$TypT,v2::$TypT) = zipWith(.*,v1,v2)
    @eval ./{T}(v1::$TypT,v2::$TypT) = zipWith(./,v1,v2)
    @eval .^{T}(v1::$TypT,v2::$TypT) = zipWith(.^,v1,v2)

    # reductions
    @eval sum{T}(v::$TypT) = fold(+,zero(T),v)
    @eval prod{T}(v::$TypT) = fold(*,one(T),v)

    @eval dot{T}(v1::$TypT,v2::$TypT) = sum(v1.*conj(v2))
end

export Vector2, Vector3, Vector4
export zipWith, fold

end
