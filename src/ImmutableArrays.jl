module ImmutableArrays

importall Base

abstract ImmutableArray{T,N} <: AbstractArray{T,N}
typealias ImmutableVector{T} ImmutableArray{T,1}
typealias ImmutableMatrix{T} ImmutableArray{T,2}

const maxDim = 4
export Vector2, Vector3, Vector4,
Matrix2x2, Matrix2x3, Matrix2x4,
Matrix3x2, Matrix3x3, Matrix3x4,
Matrix4x2, Matrix4x3, Matrix4x4

export unit, row, column

# vector types
for n = 2:maxDim
    local Typ = symbol(string("Vector",n))
    local TypT = Expr(:curly, Typ, :T)
    vecmem(i) = Expr(:quote,symbol(string("e",i)))

    # the body of the type definition
    local defn = :(immutable $TypT <: ImmutableVector{T} end)

    # the members of the type
    for i = 1:n
        local elt = vecmem(i).args[1]
        push!(defn.args[3].args, :($elt::T))
    end

    # inner unary and n-ary constructors
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

    # outer unary and n-ary constructors
    ctorn = :($TypT() = $TypT())
    ctor1 = :($TypT(a::T) = $TypT(a))
    for i = 1:n
        local arg = symbol(string("a",i))
        push!(ctorn.args[1].args, :($arg::T))
        push!(ctorn.args[2].args, arg)
    end
    eval(ctorn)
    eval(ctor1)

    # define getindex
    local getix = :(error(BoundsError))
    for i = n:-1:1
        local elt = vecmem(i)
        getix = :(ix == $i ? v.($elt) : $getix)
    end
    getix = :(getindex{T}(v::$TypT, ix::Integer) = $getix)
    eval(getix)

    # functions for defining methods
    mapBody(f,j) = begin
        mp = :($TypT())
        for i = 1:n
            local elt = vecmem(i)
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
            local elt = vecmem(i)
            push!(zp.args, Expr(:call,f,:(v1.($elt)),:(v2.($elt))))
        end
        @eval $f{T}(v1::$TypT,v2::$TypT) = $zp
    end

    foldMethod(m,f,s) = begin
        fl = s
        for i = 1:n
            local elt = vecmem(i)
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
    @eval unit{T}(v::$TypT) = v/norm(v)
end

# (column-major) matrix types
for n = 2:maxDim
    for m = 2:maxDim
        local Typ = symbol(string("Matrix",n,"x",m))
        local TypT = Expr(:curly, Typ, :T)
        local ColTyp = symbol(string("Vector",n))
        local ColTypT = Expr(:curly, ColTyp, :T)
        local RowTyp = symbol(string("Vector",m))
        local RowTypT = Expr(:curly, RowTyp, :T)
        colmem(i) = Expr(:quote,symbol(string("c",i)))
        vecmem(i) = Expr(:quote,symbol(string("e",i)))

        # the body of the type definition
        local defn = :(immutable $TypT <: ImmutableMatrix{T} end)

        # the members of the type
        for i = 1:m
            local c = colmem(i).args[1]
            push!(defn.args[3].args, :($c::$ColTypT))
        end

        # instantiate the type definition
        eval(defn)

        # column access
        local cl = :(error(BoundsError))
        for i = m:-1:1
            local elt = colmem(i)
            cl = :(ix == $i ? m.($elt) : $cl)
        end
        cl = :(column{T}(m::$TypT, ix::Integer) = $cl)
        eval(cl)

        # row access
        local rw = :(error(BoundsError))
        for i = n:-1:1
            local rowexp = :($RowTypT())
            local vecelt = vecmem(i)
            for j = 1:m
                local colelt = colmem(j)
                push!(rowexp.args, :(m.($colelt).($vecelt)))
            end
            rw = :(ix == $i ? $rowexp : $rw)
        end
        rw = :(row{T}(m::$TypT, ix::Integer) = $rw)
        eval(rw)

        # getindex
        @eval getindex{T}(m::$TypT, i::Integer, j::Integer) = column(m,j)[i]

        # some one-liners
        @eval similar{T}(::$TypT, t::DataType, dims::Dims) = Array(t, dims)
        @eval size(::$Typ) = ($n,$m)
    end
end

cross(a::Vector3,b::Vector3) =
    Vector3(a.e2*b.e3-a.e3*b.e2, a.e3*b.e1-a.e1*b.e3, a.e1*b.e2-a.e2*b.e1)

end
