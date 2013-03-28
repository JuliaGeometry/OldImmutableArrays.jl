module ImmutableArrays

importall Base

abstract ImmutableArray{T,N} <: AbstractArray{T,N}
typealias ImmutableVector{T} ImmutableArray{T,1}
typealias ImmutableMatrix{T} ImmutableArray{T,2}

# generate the vector types
export Vector2, Vector3, Vector4
for n = 2:4
    local Typ = symbol(string("Vector",n))
    local TypT = Expr(:curly, Typ, :T)
    element(i) = Expr(:quote,symbol(string("e",i)))

    # the body of the type definition
    local defn = :(immutable $TypT <: ImmutableVector{T} end)

    # the members of the type
    for i = 1:n
        local elt = element(i).args[1]
        push!(defn.args[3].args, :($elt::T))
    end

    # unary, n-ary constructors
    local ctorn = :($Typ() = new())
    local ctor1 = :($Typ(a) = new())
    for i = 1:n
        local arg = symbol(string("a",i))
        push!(ctorn.args[1].args, arg)
        push!(ctorn.args[2].args, arg)
        push!(ctor1.args[2].args, :a)
    end
    push!(defn.args[3].args, ctorn)
    push!(defn.args[3].args, ctor1)

    # instantiate the type definition
    eval(defn)

    # define getindex
    local getix = :(error(BoundsError))
    for i = n:-1:1
        local elt = element(i)
        getix = :(if ix == $i return v.($elt) else $getix end)
    end
    getix = :(getindex{T}(v::$TypT, ix::Integer) = $getix)
    eval(getix)

    # functions for defining methods
    mapBody(f,j) = begin
        mp = :($TypT())
        for i = 1:n
            local elt = element(i)
            local ff = copy(f)
            ff.args[j] = :(v.($elt))
            push!(mp.args, ff)
        end
        mp
    end
    mapMethod(f) = begin
        local bdy = mapBody(:($f(x)),2)
        @eval $f{T}(v::$TypT) = $bdy
    end
    mapBinOpLeftMethod(op) = begin
        local bdy = mapBody(:($op(s,x)),3)
        @eval $op{T}(s::Number,v::$TypT) = $bdy
    end
    mapBinOpRightMethod(op) = begin
        local bdy = mapBody(:($op(x,s)),2)
        @eval $op{T}(v::$TypT,s::Number) = $bdy
    end

    zipWithMethod(f) = begin
        zp = :($TypT())
        for i = 1:n
            local elt = element(i)
            push!(zp.args, Expr(:call,f,:(v1.($elt)),:(v2.($elt))))
        end
        @eval $f{T}(v1::$TypT,v2::$TypT) = $zp
    end

    foldMethod(m,f,s) = begin
        fl = s
        for i = 1:n
            local elt = element(i)
            fl = Expr(:call,f,fl,:(v.($elt)))
        end
        @eval $m{T}(v::$TypT) = $fl
    end

    # pointwise unary operations
    mapMethod(:-)
    mapMethod(:conj)

    # pointwise binary operations
    zipWithMethod(:+)
    zipWithMethod(:-)
    zipWithMethod(:.*)
    zipWithMethod(:./)
    zipWithMethod(:.^)
    mapBinOpLeftMethod(:+)
    mapBinOpLeftMethod(:-)
    mapBinOpLeftMethod(:.*)
    mapBinOpLeftMethod(:./)
    mapBinOpLeftMethod(:.^)
    mapBinOpRightMethod(:+)
    mapBinOpRightMethod(:-)
    mapBinOpRightMethod(:.*)
    mapBinOpRightMethod(:./)
    mapBinOpRightMethod(:.^)

    # reductions
    foldMethod(:sum,:+,:(zero(T)))
    foldMethod(:prod,:*,:(one(T)))

    # some one-liners
    @eval similar{T}(::$TypT, t::DataType, dims::Dims) = Array(t, dims)
    @eval size(::$Typ) = ($n,)
    @eval zero{T}(::Type{$TypT}) = $TypT(zero(T))
    @eval dot{T}(v1::$TypT,v2::$TypT) = sum(v1.*conj(v2))
    @eval norm{T}(v::$TypT) = sqrt(dot(v,v))
end

end
