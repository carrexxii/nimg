import common

type Fatal* = enum
    DebugCheck
    InvalidShader
    UnableToInitialize
    UnableToCreateTexture
    DeviceLost

type DebugFlag* = distinct uint32
const
    DebugNone*      = DebugFlag 0x0000_0000
    DebugWireFrame* = DebugFlag 0x0000_0001
    DebugIFH*       = DebugFlag 0x0000_0002
    DebugStats*     = DebugFlag 0x0000_0004
    DebugText*      = DebugFlag 0x0000_0008
    DebugProfiler*  = DebugFlag 0x0000_0010
proc `or`*(a, b: DebugFlag): DebugFlag {.borrow.}

proc set_debug*(debug: DebugFlag)                                        {.importc: "bgfx_set_debug"      , dynlib: BGFXPath.}
proc debug_text_clear*(attr: byte, small: bool)                          {.importc: "bgfx_dbg_text_clear" , dynlib: BGFXPath.}
proc debug_text_printf*(x, y: uint16, attr: byte, fmt: cstring)          {.importc: "bgfx_dbg_text_printf", dynlib: BGFXPath, varargs.}
proc debug_text_image*(x, y, w, h: uint16, data: pointer, pitch: uint16) {.importc: "bgfx_dbg_text_image" , dynlib: BGFXPath.}
