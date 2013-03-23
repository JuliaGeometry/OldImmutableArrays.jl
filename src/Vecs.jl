module Vecs


# Basic types

immutable Vec2{T}
    x :: T
    y :: T
end
immutable Vec3{T}
    x :: T
    y :: T
    z :: T
end
immutable Vec4{T}
    x :: T
    y :: T
    z :: T
    w :: T
end
export Vec2, Vec3, Vec4


# Type aliases

typealias Vec2f Vec2{Float32}
typealias Vec3f Vec3{Float32}
typealias Vec4f Vec4{Float32}
typealias Vec2d Vec2{Float64}
typealias Vec3d Vec3{Float64}
typealias Vec4d Vec4{Float64}
typealias Mat22{T} Vec2{Vec2{T}}
typealias Mat23{T} Vec2{Vec3{T}}
typealias Mat24{T} Vec2{Vec4{T}}
typealias Mat32{T} Vec3{Vec2{T}}
typealias Mat33{T} Vec3{Vec3{T}}
typealias Mat34{T} Vec3{Vec4{T}}
typealias Mat42{T} Vec4{Vec2{T}}
typealias Mat43{T} Vec4{Vec3{T}}
typealias Mat44{T} Vec4{Vec4{T}}
typealias Mat2{T} Mat22{T}
typealias Mat3{T} Mat33{T}
typealias Mat4{T} Mat44{T}
typealias Mat22f Vec2{Vec2f}
typealias Mat23f Vec2{Vec3f}
typealias Mat24f Vec2{Vec4f}
typealias Mat32f Vec3{Vec2f}
typealias Mat33f Vec3{Vec3f}
typealias Mat34f Vec3{Vec4f}
typealias Mat42f Vec4{Vec2f}
typealias Mat43f Vec4{Vec3f}
typealias Mat44f Vec4{Vec4f}
typealias Mat2f Mat22f
typealias Mat3f Mat33f
typealias Mat4f Mat44f
typealias Mat22d Vec2{Vec2d}
typealias Mat23d Vec2{Vec3d}
typealias Mat24d Vec2{Vec4d}
typealias Mat32d Vec3{Vec2d}
typealias Mat33d Vec3{Vec3d}
typealias Mat34d Vec3{Vec4d}
typealias Mat42d Vec4{Vec2d}
typealias Mat43d Vec4{Vec3d}
typealias Mat44d Vec4{Vec4d}
typealias Mat2d Mat22d
typealias Mat3d Mat33d
typealias Mat4d Mat44d

export Vec2f, Vec3f, Vec4f, Vec2d, Vec3d, Vec4d, 
Mat22, Mat23, Mat24, Mat32, Mat33, Mat34, 
Mat42, Mat43, Mat44, Mat2, Mat3, Mat4, 
Mat22f, Mat23f, Mat24f, Mat32f, Mat33f, Mat34f, 
Mat42f, Mat43f, Mat44f, Mat2f, Mat3f, Mat4f, 
Mat22d, Mat23d, Mat24d, Mat32d, Mat33d, Mat34d, 
Mat42d, Mat43d, Mat44d, Mat2d, Mat3d, Mat4d 


# Indexing

import Base.getindex

function getindex{T}(v::Vec2{T}, i::Integer)
    if i == 1
        return v.x
    elseif i == 2 
        return v.y
    else
        throw("Invalid index for Vec2: $i")
    end
end

function getindex{T}(v::Vec3{T}, i::Integer)
    if i == 1
        return v.x
    elseif i == 2 
        return v.y
    elseif i == 3 
        return v.z
    else
        throw("Invalid index for Vec3: $i")
    end
end

function getindex{T}(v::Vec4{T}, i::Integer)
    if i == 1
        return v.x
    elseif i == 2 
        return v.y
    elseif i == 3 
        return v.z
    elseif i == 4 
        return v.w
    else
        throw("Invalid index for Vec4: $i")
    end
end


# Basic operations

importall Base

+{T}(v1::Vec2{T},v2::Vec2{T}) = Vec2{T}(v1.x+v2.x,v1.y+v2.y)
-{T}(v1::Vec2{T},v2::Vec2{T}) = Vec2{T}(v1.x-v2.x,v1.y-v2.y)
.*{T}(v1::Vec2{T},v2::Vec2{T}) = Vec2{T}(v1.x.*v2.x,v1.y.*v2.y)
./{T}(v1::Vec2{T},v2::Vec2{T}) = Vec2{T}(v1.x./v2.x,v1.y./v2.y)
.^{T}(v1::Vec2{T},v2::Vec2{T}) = Vec2{T}(v1.x.^v2.x,v1.y.^v2.y)

+{T}(v1::Vec3{T},v2::Vec3{T}) = Vec3{T}(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z)
-{T}(v1::Vec3{T},v2::Vec3{T}) = Vec3{T}(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
.*{T}(v1::Vec3{T},v2::Vec3{T}) = Vec3{T}(v1.x.*v2.x,v1.y.*v2.y,v1.z.*v2.z)
./{T}(v1::Vec3{T},v2::Vec3{T}) = Vec3{T}(v1.x./v2.x,v1.y./v2.y,v1.z./v2.z)
.^{T}(v1::Vec3{T},v2::Vec3{T}) = Vec3{T}(v1.x.^v2.x,v1.y.^v2.y,v1.z.^v2.z)

+{T}(v1::Vec4{T},v2::Vec4{T}) = Vec4{T}(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z,v1.w+v2.w)
-{T}(v1::Vec4{T},v2::Vec4{T}) = Vec4{T}(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z,v1.w-v2.w)
.*{T}(v1::Vec4{T},v2::Vec4{T}) = Vec4{T}(v1.x.*v2.x,v1.y.*v2.y,v1.z.*v2.z,v1.w.*v2.w)
./{T}(v1::Vec4{T},v2::Vec4{T}) = Vec4{T}(v1.x./v2.x,v1.y./v2.y,v1.z./v2.z,v1.w./v2.w)
.^{T}(v1::Vec4{T},v2::Vec4{T}) = Vec4{T}(v1.x.^v2.x,v1.y.^v2.y,v1.z.^v2.z,v1.w.^v2.w)

end
