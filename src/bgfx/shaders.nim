from std/strformat import fmt
import common
import memory
import ../debug

const ShaderDir = "./shaders/bin"

type
    ShaderHandle*  = distinct uint16
    UniformHandle* = distinct uint16
    ProgramHandle* = distinct uint16
    ShaderStage*   = distinct uint8

proc create_shader*(memory: ptr Memory): ShaderHandle                                             {.importc: "bgfx_create_shader"      , dynlib: BGFXPath.}
proc destroy_shader*(shader: ShaderHandle)                                                        {.importc: "bgfx_destroy_shader"     , dynlib: BGFXPath.}
proc get_shader_uniforms*(shader: ShaderHandle, uniforms: ptr UniformHandle, max: uint16): uint16 {.importc: "bgfx_get_shader_uniforms", dynlib: BGFXPath.}

proc create_program*(vs, fs: ShaderHandle, destroy_shaders: bool): ProgramHandle {.importc: "bgfx_create_program" , dynlib: BGFXPath.}
proc destroy_program*(program: ProgramHandle)                                    {.importc: "bgfx_destroy_program", dynlib: BGFXPath.}

proc create_program*(name: string): ProgramHandle =
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
