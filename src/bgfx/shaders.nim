import std/strformat
import bgfx
import ../debug

const ShaderDir = "./shaders/bin"

type
    Shader*  = distinct uint16
    Uniform* = distinct uint16
    Program* = distinct uint16

proc create_shader*(memory: ptr Memory): Shader                                       {.importc: "bgfx_create_shader"      , dynlib: LibPath.}
proc destroy_shader*(shader: Shader)                                                  {.importc: "bgfx_destroy_shader"     , dynlib: LibPath.}
proc get_shader_uniforms*(shader: Shader, uniforms: ptr Uniform, max: uint16): uint16 {.importc: "bgfx_get_shader_uniforms", dynlib: LibPath.}

proc create_program*(vs, fs: Shader, destroy_shaders: bool): Program {.importc: "bgfx_create_program" , dynlib: LibPath.}
proc destroy_program*(program: Program)                              {.importc: "bgfx_destroy_program", dynlib: LibPath.}

proc create_program*(name: string): Program =
    try:
        var
            vs_data   = read_file fmt"{ShaderDir}/{name}.vs.bin"
            fs_data   = read_file fmt"{ShaderDir}/{name}.fs.bin"
            vs_mem    = bgfx.copy(cast[pointer](vs_data.cstring), uint32 vs_data.len)
            fs_mem    = bgfx.copy(cast[pointer](fs_data.cstring), uint32 fs_data.len)
        let vs = create_shader vs_mem
        let fs = create_shader fs_mem
        result = create_program(vs, fs, true)
    except IOError:
        echo red fmt"Filed to open files for shader program '{name}'"
        return

    echo green fmt"Created shader program for '{name}'"
