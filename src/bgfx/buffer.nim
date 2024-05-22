import common
import memory
from init import RendererKind, get_renderer_type
from ../cglm/cglm import Mat4x4

type
    Attrib* = enum
        Position
        Normal
        Tangent
        BiTangent
        Colour0, Colour1, Colour2, Colour3
        Indices
        Weight
        TexCoord0, TexCoord1, TexCoord2, TexCoord3, TexCoord4, TexCoord5, TexCoord6, TexCoord7
    AttribKind* = enum
        UInt8
        UInt10
        Int16
        Half
        Float

type
    VBO*     = distinct uint16
    DVBO*    = distinct uint16
    TVBO*    = distinct uint16
    IBO*     = distinct uint16
    DIBO*    = distinct uint16
    TIBO* = object
        data    : ptr UncheckedArray[uint8]
        size    : uint32
        start   : uint32
        ibo     : IBO
        is_16bit: bool

    Uniform* = distinct uint16
    Texture* = distinct uint16

    VBOLayoutHandle* = distinct uint16
    VBOLayout* = object
        hash   : uint32
        stride : uint16
        offsets: array[high(Attrib).int + 1, uint16]
        attribs: array[high(Attrib).int + 1, uint16]
    VertexStream* = distinct uint8

    Instance* = object
        data  : ptr UncheckedArray[uint8]
        size  : uint32
        offset: uint32
        count : uint32
        stride: uint16
        vbo   : VBO

    Transform* = object
        data : ptr UncheckedArray[Mat4x4]
        count: uint16

    ScissorCache* = distinct uint16
    MatrixCache*  = distinct uint32

proc create_ibo*(mem: ptr Memory; flags: BufferFlag): IBO {.importc: "bgfx_create_index_buffer" , dynlib: BGFXPath.}
proc destroy_ibo*(handle: IBO)                            {.importc: "bgfx_destroy_index_buffer", dynlib: BGFXPath.}

proc create_vbo_layout*(layout: ptr VBOLayout): VBOLayoutHandle                                                            {.importc: "bgfx_create_vertex_layout" , dynlib: BGFXPath.}
proc destroy_vbo_layout*(handle: VBOLayoutHandle)                                                                          {.importc: "bgfx_destroy_vertex_layout", dynlib: BGFXPath.}
proc begin_vbo_layout*(layout: ptr VBOLayout; renderer: RendererKind): ptr VBOLayout                                       {.importc: "bgfx_vertex_layout_begin"  , dynlib: BGFXPath.}
proc add*(layout: ptr VBOLayout; attr: Attrib; num: uint8; attr_kind: AttribKind; normalized, as_int: bool): ptr VBOLayout {.importc: "bgfx_vertex_layout_add"    , dynlib: BGFXPath.}
proc end_vbo_layout*(layout: ptr VBOLayout)                                                                                {.importc: "bgfx_vertex_layout_end"    , dynlib: BGFXPath.}
proc create_vbo_layout*(attrs: varargs[tuple[attr: Attrib, count: int; kind: AttribKind]]): VBOLayout =
    discard begin_vbo_layout(result.addr, get_renderer_type())
    for (attr, count, kind) in attrs:
        discard add(result.addr, attr, count.uint8, kind, true, false)
    end_vbo_layout result.addr

proc create_vbo*(mem: ptr Memory; layout: ptr VBOLayout; flags: BufferFlag): VBO {.importc: "bgfx_create_vertex_buffer" , dynlib: BGFXPath.}
proc destroy_vbo*(handle: VBO)                                                   {.importc: "bgfx_destroy_vertex_buffer", dynlib: BGFXPath.}

proc set_uniform*(handle: Uniform; val: pointer; num: uint16) {.importc: "bgfx_set_uniform", dynlib: BGFXPath.}
proc set_uniform*(handle: Uniform; val: pointer) =
    set_uniform(handle, val, high uint16)

proc set_ibo*(handle: IBO; first_idx, num_indices: uint32)                                                 {.importc: "bgfx_set_index_buffer", dynlib: BGFXPath.}
proc set_vbo*(stream: VertexStream; handle: VBO; start_vertex, num_vertices: uint32)                          {.importc: "bgfx_set_vertex_buffer", dynlib: BGFXPath.}
proc set_vbo*(stream: VertexStream; handle: VBO; start_vertex, num_vertices: uint32; layout: VBOLayoutHandle) {.importc: "bgfx_set_vertex_with_layout", dynlib: BGFXPath.}
proc set_vertex_count*(num_vertices: uint32) {.importc: "bgfx_set_vertex_count", dynlib: BGFXPath.}
