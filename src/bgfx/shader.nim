from std/strformat import fmt
import common, memory, buffer

const ShaderDir = "./shaders/bin"

type
    Shader*         = distinct uint16
    Program*        = distinct uint16
    ViewID*         = distinct uint16
    ShaderStage*    = distinct uint8
    IndirectHandle* = distinct uint16
    MIPLevel*       = distinct uint8
    OcclusionQuery* = distinct uint16

proc create_shader*(memory: ptr Memory): Shader                                {.importc: "bgfx_create_shader"      , dynlib: BGFXPath.}
proc destroy_shader*(shader: Shader)                                           {.importc: "bgfx_destroy_shader"     , dynlib: BGFXPath.}
proc get_uniforms*(shader: Shader, uniforms: ptr Uniform, max: uint16): uint16 {.importc: "bgfx_get_shader_uniforms", dynlib: BGFXPath.}

proc create_program*(vs, fs: Shader, destroy_shaders: bool): Program {.importc: "bgfx_create_program" , dynlib: BGFXPath.}
proc destroy_program*(program: Program)                              {.importc: "bgfx_destroy_program", dynlib: BGFXPath.}

proc set_view_clear*(view_id: ViewID, flags: ClearFlag, colour: uint32, depth: float32, stencil: byte) {.importc: "bgfx_set_view_clear", dynlib: BGFXPath.}
proc set_view_rect*(view_id: ViewID, x, y, w, h: uint16) {.importc: "bgfx_set_view_rect", dynlib: BGFXPath.}

proc set_texture*(stage: ShaderStage; sampler: Uniform; handle: Texture; flags: SamplerFlag) {.importc: "bgfx_set_texture", dynlib: BGFXPath.}

proc create_program*(name: string): Program =
    try:
        var
            vs_data = read_file fmt"{ShaderDir}/{name}.vs.bin"
            fs_data = read_file fmt"{ShaderDir}/{name}.fs.bin"
            vs_mem  = copy(cast[pointer](vs_data.cstring), uint32 vs_data.len)
            fs_mem  = copy(cast[pointer](fs_data.cstring), uint32 fs_data.len)
        let vs = create_shader vs_mem
        let fs = create_shader fs_mem
        result = create_program(vs, fs, true)
    except IOError:
        echo red fmt"Filed to open files for shader program '{name}'"
        return

    echo green fmt"Created shader program for '{name}'"
