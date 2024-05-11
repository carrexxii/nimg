from std/strutils  import to_lower
from std/strformat import fmt

const IncludeDir = "../lib/cglm/include/cglm"
const CGLMHeader = IncludeDir & "/vec3.h"

# TODO: https://github.com/stavenko/nim-glm/blob/47d5f8681f3c462b37e37ebc5e7067fa5cba4d16/glm/vec.nim#L193

type
    V2[T] = object
        x*, y*: T = 1.0
    V3[T] = object
        x*, y*, z*: T
    V4[T] = object
        x*, y*, z*, w*: T

    Vec2* = V2[float32]
    Vec3* = V3[float32]
    Vec4* = V4[float32]

func `$`*[T](v: V2[T]): string = fmt"({v.x}, {v.y})"
func `$`*[T](v: V3[T]): string = fmt"({v.x}, {v.y}, {v.z})"
func `$`*[T](v: V4[T]): string = fmt"({v.x}, {v.y}, {v.z}, {v.w})"

type GLMFnKind = enum
    VecVec_Vec
    VecVec_Scalar
    Vec_Scalar
template glm_op_single(name, op, T, ret; kind: GLMFnKind) =
    const glm_str = "glm_" & (to_lower $T) & "_" & (ast_to_str name)
    when kind == VecVec_Vec:
        proc `T name`*(v, u, dest: pointer): ret {.importc: glm_str, header: CGLMHeader.}
        template `op`*(v, u: T): T =
            var result: T
            `T name`(v.addr, u.addr, result.addr)
            result
    elif kind == VecVec_Scalar:
        proc `T name`*(v, u: pointer): ret {.importc: glm_str, header: CGLMHeader.}
        template `op`*(v, u: T): ret =
            `T name`(v.addr, u.addr)
    elif kind == Vec_Scalar:
        proc `T name`*(v: pointer): ret {.importc: glm_str, header: CGLMHeader.}
        template `op`*(v: T): ret =
            `T name` v.addr

template glm_op(name, op, ret, kind) =
    glm_op_single(name, op, Vec2, ret, kind)
    glm_op_single(name, op, Vec3, ret, kind)
    glm_op_single(name, op, Vec4, ret, kind)

template glm_func(name, ret) =
    const
        glm_str_v2 = "glm_" & (to_lower $Vec2) & "_" & (ast_to_str name)
        glm_str_v3 = "glm_" & (to_lower $Vec3) & "_" & (ast_to_str name)
        glm_str_v4 = "glm_" & (to_lower $Vec4) & "_" & (ast_to_str name)
    proc `Vec2 name`*(v: pointer): ret {.importc: glm_str_v2, header: CGLMHeader.}
    proc `Vec3 name`*(v: pointer): ret {.importc: glm_str_v3, header: CGLMHeader.}
    proc `Vec4 name`*(v: pointer): ret {.importc: glm_str_v4, header: CGLMHeader.}
    template name*(v): ret =
        when v is Vec2: `Vec2 name` v.addr
        elif v is Vec3: `Vec3 name` v.addr
        elif v is Vec4: `Vec4 name` v.addr

glm_op(add, `+`, void, VecVec_Vec)
glm_op(sub, `-`, void, VecVec_Vec)
glm_op(mul, `*`, void, VecVec_Vec)
glm_op(vdi, `/`, void, VecVec_Vec)

glm_op(dot, `∙`, float32, VecVec_Scalar) # \bullet

glm_func(norm , float32)
glm_func(norm2, float32)
