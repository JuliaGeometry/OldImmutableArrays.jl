importall Base

using Compat

abstract ImmutableArray{T,N} <: AbstractArray{T,N}
typealias ImmutableVector{T} ImmutableArray{T,1}
typealias ImmutableMatrix{T} ImmutableArray{T,2}

export unit, row, column

# Generic ops
Base.copy(x::ImmutableArray) = x
Base.one{M<:ImmutableMatrix}(::M) = eye(M)

function generate_arrays(maxSz::Integer)

    # operations
    const unaryOps = (:-, :~, :conj, :abs, 
                      :sin, :cos, :tan, :sinh, :cosh, :tanh, 
                      :asin, :acos, :atan, :asinh, :acosh, :atanh,
                      :sec, :csc, :cot, :asec, :acsc, :acot,
                      :sech, :csch, :coth, :asech, :acsch, :acoth,
                      :sinc, :cosc, :cosd, :cotd, :cscd, :secd,
                      :sind, :tand, :acosd, :acotd, :acscd, :asecd,
                      :asind, :atand, :radians2degrees, :degrees2radians,
                      :log, :log2, :log10, :log1p, :exponent, :exp,
                      :exp2, :expm1, :cbrt, :sqrt, :square, :erf, 
                      :erfc, :erfcx, :erfi, :dawson, :ceil, :floor,
                      :trunc, :round, :significand, :lgamma, :hypot,
                      :gamma, :lfact, :frexp, :modf, :airy, :airyai,
                      :airyprime, :airyaiprime, :airybi, :airybiprime,
                      :besselj0, :besselj1, :bessely0, :bessely1,
                      :eta, :zeta, :digamma)

    # vec-vec and vec-scalar
    const binaryOps = (:.+, :.-,:.*, :./, :.\, :.^, 
                       :.==, :.!=, :.<, :.<=, :.>, :.>=,
                       :min, :max,
                       :div, :fld, :rem, :mod, :mod1, :cmp,
                       :atan2, :besselj, :bessely, :hankelh1, :hankelh2, 
                       :besseli, :besselk, :beta, :lbeta)
    
    # vec-vec only
    const binaryOps2 = (:+,:-)

    const reductions = ((:sum,:+),(:prod,:*),(:minimum,:min),(:maximum,:max))

    # expression functions
    vecTyp(n) = @compat Symbol(string("Vector",n))
    vecTypT(n) = Expr(:curly, vecTyp(n), :T)
    matTyp(r,c) = @compat Symbol(string("Matrix",r,"x",c))
    matTypT(r,c) = Expr(:curly, matTyp(r,c,), :T)
    elt(i) = @compat Symbol(string("e",i))
    col(i) = @compat Symbol(string("c",i))
    mem(s,e) = Expr(:.,s,Expr(:quote,e))
    velt(v,i) = mem(v,elt(i))
    melt(m,i,j) = mem(mem(m,col(j)),elt(i))

    # vector types
    for sz = 1:maxSz
        local Typ = vecTyp(sz)
        local TypT = vecTypT(sz)

        # the body of the type definition
        local defn = :(immutable $TypT <: ImmutableVector{T} end)

        # the members of the type
        for i = 1:sz
            local e = elt(i)
            push!(defn.args[3].args, :($e::T))
        end

        # instantiate the type definition
        eval(defn)

        # unary and n-ary constructors
        ctorn_sig = :($TypT())
        ctorn_body = :($TypT())
        ctor1_body = :($TypT())
        for i = 1:sz
            local arg = @compat Symbol(string("a",i))
            push!(ctorn_sig.args, :($arg::T))
            push!(ctorn_body.args, arg)
            push!(ctor1_body.args, :a)
        end
        ctorn = :($ctorn_sig = $ctorn_body)
        ctor1 = :($TypT(a::T) = $ctor1_body)
        eval(ctorn)
        eval(ctor1)

        # construct or convert from other vector types
        typ_call = :($Typ())
        # makes $Typ(a[1], a[2]..., a[sz])
        append!(typ_call.args, [:(a[$i]) for i = 1:sz])
        @eval $Typ(a::AbstractVector) = $typ_call
        convert_call = :($Typ())
        # makes $Typ(convert(T, a[1]), ..., convert(T, a[sz]))
        append!(convert_call.args, [:(convert(T, a[$i])) for i = 1:sz])
        @eval convert{T}(::Type{$TypT}, a::AbstractVector) = $convert_call

        # convert to Array
        @eval begin
            function convert{T}(::Type{Vector{T}}, v::$TypT)
                a = Array(T,$sz)
                for i = 1:$sz
                    a[i] = v[i]
                end
                a
            end
        end

        # equality
        # this generates messy lowered code but the assembly looks fine
        equalities = [:(a[$i] == b[$i]) for i = 1:sz]
        while length(equalities) > 1
            equalities[1] = :($(equalities[1]) && $(equalities[2]))
            deleteat!(equalities, 2)
        end
        eq_bdy = equalities[1]
        @eval (==)(a::$Typ, b::$Typ) = $eq_bdy

        # getindex
        local getix = :(throw(BoundsError()))
        for i = sz:-1:1
            local val = mem(:v,elt(i))
            getix = :(ix == $i ? $val : $getix)
        end
        getix = :(@inline getindex{T}(v::$TypT, ix::Integer) = $getix)
        eval(getix)

        # helper for defining maps
        mapBody(f,j) = begin
            mp = :($Typ())
            for i = 1:sz
                local ff = copy(f)
                ff.args[j] = mem(:v,elt(i))
                push!(mp.args, ff)
            end
            mp
        end

        for op = unaryOps
            local bdy = mapBody(:($op(x)),2)
            @eval $op(v::$Typ) = $bdy
        end

        for op = binaryOps
            local bdy = :($Typ())
            for i = 1:sz
                local mem1 = mem(:v1,elt(i))
                local mem2 = mem(:v2,elt(i))
                push!(bdy.args, Expr(:call,op,mem1,mem2))
            end
            @eval $op(v1::$Typ,v2::$Typ) = $bdy

            bdy = mapBody(:($op(s,x)),3)
            if op == :.^ # special version for MathConst{:e}
                @eval $op(s::Irrational{:e},m::$Typ) = $bdy
            end
            if op == :min || op == :max
                @eval $op{T2<:Real}(s::T2,v::$Typ) = $bdy
            else
                @eval $op(s::Number,v::$Typ) = $bdy
            end

            bdy = mapBody(:($op(x,s)),2)
            if op == :min || op == :max
                @eval $op{T2<:Real}(v::$Typ,s::T2) = $bdy
            else
                @eval $op(v::$Typ,s::Number) = $bdy
            end
        end
        
        for op = binaryOps2
            local bdy = :($Typ())
            for i = 1:sz
                local mem1 = mem(:v1,elt(i))
                local mem2 = mem(:v2,elt(i))
                push!(bdy.args, Expr(:call,op,mem1,mem2))
            end
            @eval $op(v1::$Typ,v2::$Typ) = $bdy
        end

        for pr = reductions
            local bdy = Expr(:call,pr[2])
            for i = 1:sz
                push!(bdy.args, mem(:v,elt(i)))
            end
            local meth = pr[1]
            @eval $meth(v::$Typ) = $bdy
        end

        # convert to column matrix
        local colMatT = matTypT(sz,1)
        @eval column{T}(v::$TypT) = $colMatT(v)

        # convert to row matrix
        local rowMat = Expr(:call,matTyp(1,sz))
        for i = 1:sz
            local val = mem(:v,elt(i))
            push!(rowMat.args, :(Vector1{T}($val)))
        end
        @eval row{T}(v::$TypT) = $rowMat

        # vector norms
        @eval norm{T}(v::$TypT) = sqrt(dot(v,v))
        @eval norm{T}(v::$TypT,p::Number) = begin
            if p == 1
                sum(abs(v))
            elseif p == 2
                norm(v)
            elseif p == Inf
                max(abs(v))
            else
                norm(copy(v),p)
            end
        end

        # standard basis vectors
        local bdy = :($TypT())
        for j = 1:sz
            push!(bdy.args, :(i==$j?one(T):zero(T)))
        end
        @eval unit{T}(::Type{$TypT}, i::Integer) = $bdy

        # diagonal matrix
        sqMatTypT = matTypT(sz,sz)
        bdy = :($sqMatTypT())
        for i = 1:sz
            push!(bdy.args, :(v[$i].*unit($TypT,$i)))
        end
        @eval diagm{T}(v::$TypT) = $bdy

        # elementwise type conversion
        bdy = mapBody(:(convert(T,x)),3)
        @eval convert{T}(::Type{$TypT}, v::$Typ) = $bdy

        # some one-liners
        @eval similar{T}(::$TypT, t::DataType, dims::Dims) = Array(t, dims)
        @eval size(::$Typ) = ($sz,)
        @eval zero{T}(::Type{$TypT}) = $Typ(zero(T))
        @eval dot{T}(v1::$TypT,v2::$TypT) = sum(v1.*conj(v2))
        @eval unit{T}(v::$TypT) = v/norm(v)
    end

    # matrix types
    for rSz = 1:maxSz, cSz = 1:maxSz
        local Typ = matTyp(rSz,cSz)
        local TypT = matTypT(rSz,cSz)
        local ColTyp = vecTyp(rSz)
        local ColTypT = vecTypT(rSz)
        local RowTyp = vecTyp(cSz)
        local RowTypT = vecTypT(cSz)

        # the body of the type definition
        local defn = :(immutable $TypT <: ImmutableMatrix{T} end)

        # the members of the type
        for i = 1:cSz
            local c = col(i)
            push!(defn.args[3].args, :($c::$ColTypT))
        end

        # instantiate the type definition
        eval(defn)

        # unary and n-ary constructors
        ctorn_sig = :($TypT())
        ctorn_body = :($TypT())
        ctor1_body = :($TypT())
        for i = 1:cSz
            local arg = @compat Symbol(string("a",i))
            push!(ctorn_sig.args, :($arg::$ColTypT))
            push!(ctorn_body.args, arg)
            push!(ctor1_body.args, :a)
        end
        ctorn = :($ctorn_sig = $ctorn_body)
        ctor1 = :($TypT(a::$ColTypT) = $ctor1_body)
        eval(ctorn)
        eval(ctor1)

        # construction from a scalar
        @eval $TypT(a::T) = $Typ($ColTyp(a))

        # construct or convert from other matrix types
        # accomidate ntuple syntax change on 0.4
        if VERSION < v"0.4-"
            @eval $Typ(a::AbstractMatrix) = $Typ(ntuple($cSz, c->
                $ColTyp(ntuple($rSz, r-> a[r,c])...))...)
        else
            @eval $Typ(a::AbstractMatrix) = $Typ(ntuple(c->
                $ColTyp(ntuple(r-> a[r,c], $rSz)...), $cSz)...)
        end
        @eval convert{T}(::Type{$TypT}, x::AbstractMatrix) = $Typ(x)

        # convert to Array
        @eval begin
            function convert{T}(::Type{Matrix{T}}, m::$TypT)
                a = Array(T,$rSz,$cSz)
                for i = 1:$rSz, j = 1:$cSz
                    a[i,j] = m[i,j]
                end
                a
            end
        end

        # column access
        local cl = :(error(BoundsError))
        for j = cSz:-1:1
            local val = mem(:m,col(j))
            cl = :(ix == $j ? $val : $cl)
        end
        @eval column{T}(m::$TypT, ix::Integer) = $cl

        # row access
        local rw = :(error(BoundsError))
        for i = rSz:-1:1
            local rowexp = :($RowTypT())
            for j = 1:cSz
                push!(rowexp.args, mem(mem(:m,col(j)),elt(i)))
            end
            rw = :(ix == $i ? $rowexp : $rw)
        end
        @eval row{T}(m::$TypT, ix::Integer) = $rw

        # getindex
        @eval getindex{T}(m::$TypT, i::Integer, j::Integer) = column(m,j)[i]
        @eval getindex{T}(m::$TypT, ix::Integer) = 
            getindex(m,mod(ix-1,$rSz)+1,div(ix-1,$rSz)+1)

        # ctranspose
        local bdy = Expr(:call, matTypT(cSz,rSz))
        for i = 1:rSz
            local rw = :($RowTypT())
            for j = 1:cSz
                local val = mem(mem(:m,col(j)),elt(i))
                push!(rw.args, :(conj($val)))
            end
            push!(bdy.args, rw)
        end
        @eval ctranspose{T}(m::$TypT) = $bdy

        # helper for defining maps
        mapBody(f,k) = begin
            local bdy = :($Typ())
            for j = 1:cSz
                local cl = :($ColTyp())
                for i = 1:rSz
                    local ff = copy(f)
                    ff.args[k] = mem(mem(:m,col(j)),elt(i))
                    push!(cl.args, ff)
                end
                push!(bdy.args, cl)
            end
            bdy
        end

        for op = unaryOps
            local bdy = mapBody(:($op(x)),2)
            @eval $op(m::$Typ) = $bdy
        end

        for op = binaryOps
            local bdy = :($Typ())
            for j = 1:cSz
                local cl = :($ColTyp())
                for i = 1:rSz
                    push!(cl.args, 
                          Expr(:call,op,
                               mem(mem(:m1,col(j)),elt(i)),
                               mem(mem(:m2,col(j)),elt(i))))
                end
                push!(bdy.args, cl)
            end
            @eval $op(m1::$Typ,m2::$Typ) = $bdy

            bdy = mapBody(:($op(s,x)),3)
            if op == :.^ # special version for MathConst{:e}
                @eval $op(s::Irrational{:e},m::$Typ) = $bdy
            end
            if op == :min || op == :max
                @eval $op{T2<:Real}(s::T2,m::$Typ) = $bdy
            else
                @eval $op(s::Number,m::$Typ) = $bdy
            end

            bdy = mapBody(:($op(x,s)),2)
            if op == :min || op == :max
                @eval $op{T2<:Real}(m::$Typ,s::T2) = $bdy
            else
                @eval $op(m::$Typ,s::Number) = $bdy
            end
        end
        
        for op = binaryOps2
            local bdy = :($Typ())
            for j = 1:cSz
                local cl = :($ColTyp())
                for i = 1:rSz
                    push!(cl.args, 
                          Expr(:call,op,
                               mem(mem(:m1,col(j)),elt(i)),
                               mem(mem(:m2,col(j)),elt(i))))
                end
                push!(bdy.args, cl)
            end
            @eval $op(m1::$Typ,m2::$Typ) = $bdy
        end

        for pr = reductions
            local bdy = Expr(:call,pr[2])
            for i = 1:rSz, j = 1:cSz
                push!(bdy.args, mem(mem(:m,col(j)),elt(i)))
            end
            local meth = pr[1]
            @eval $meth(m::$Typ) = $bdy
        end

        # vector-matrix multiplication
        bdy = :($RowTypT())
        for j = 1:cSz
            local e = :(+())
            for i = 1:rSz
                push!(e.args, 
                      Expr(:call, :*,
                           mem(:v,elt(i)),
                           mem(mem(:m,col(j)),elt(i))))
            end
            push!(bdy.args, e)
        end
        @eval *{T}(v::$ColTypT,m::$TypT) = $bdy

        # matrix-vector multiplication
        bdy = :($ColTypT())
        for i = 1:rSz
            local e = :(+())
            for j = 1:cSz
                push!(e.args, 
                      Expr(:call, :*,
                           melt(:m,i,j),
                           velt(:v,j)))
            end
            push!(bdy.args, e)
        end
        @eval *{T}(m::$TypT,v::$RowTypT) = $bdy

        # vector-matrix-vector multiplication
        bdy = :(+())
        for i = 1:rSz, j = 1:cSz
            push!(bdy.args, 
                  Expr(:call, :*, 
                       mem(:vl,elt(i)),
                       mem(mem(:m,col(j)),elt(i)),
                       mem(:vr,elt(j))))
        end
        @eval *{T}(vl::$ColTypT,m::$TypT,vr::$RowTypT) = $bdy

        # identity
        bdy = :($TypT())
        for j = 1:cSz
            push!(bdy.args, :(unit($ColTypT,$j)))
        end
        @eval eye{T}(::Type{$TypT}) = $bdy

        # matrix diagonal
        diagSz = min(rSz,cSz)
        diagTypT = vecTypT(diagSz)
        bdy = :($diagTypT())
        for i = 1:diagSz
            push!(bdy.args, mem(mem(:m,col(i)),elt(i)))
        end
        @eval diag{T}(m::$TypT) = $bdy

        # elementwise type conversion
        bdy = mapBody(:(convert(T,x)),3)
        @eval convert{T}(::Type{$TypT}, m::$Typ) = $bdy

        # some one-liners
        @eval similar{T}(::$TypT, t::DataType, dims::Dims) = Array(t, dims)
        @eval size(::$Typ) = ($rSz,$cSz)
        @eval zero{T}(::Type{$TypT}) = $Typ($ColTyp(zero(T)))
    end

    # matrix-matrix multiplication
    for n = 1:maxSz, p = 1:maxSz, m = 1:maxSz
        local bdy = Expr(:call, matTypT(n,m))
        for j = 1:m
            local c = Expr(:call, vecTypT(n))
            for i = 1:n
                local e = :(+())
                for k = 1:p
                    push!(e.args,
                          Expr(:call, :*,
                               melt(:m1,i,k),
                               melt(:m2,k,j)))
                end
                push!(c.args, e)
            end
            push!(bdy.args, c)
        end
        local m1T = matTypT(n,p)
        local m2T = matTypT(p,m)
        @eval *{T}(m1::$m1T,m2::$m2T) = $bdy
    end

    # matrix determinant and inverse
    for sz in 1:maxSz
        local Typ = matTyp(sz,sz)
        local TypT = matTypT(sz,sz)

        @eval det{T}(a::$TypT) = det(convert(Array{T,2},a))
        @eval inv{T}(a::$TypT) = $Typ(inv(convert(Array{T,2},a)))
    end

    # cross products
    if maxSz >= 2
        @eval cross(a::Vector2,b::Vector2) = a.e1*b.e2-a.e2*b.e1
    end

    if maxSz >= 3
        @eval cross(a::Vector3,b::Vector3) = Vector3(a.e2*b.e3-a.e3*b.e2, 
                                                     a.e3*b.e1-a.e1*b.e3, 
                                                     a.e1*b.e2-a.e2*b.e1)
    end
end
