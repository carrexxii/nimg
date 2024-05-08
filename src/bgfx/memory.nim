import common

type Memory* = object
    data*: ptr byte
    size*: uint32

proc alloc*(size: uint32): ptr Memory                   {.importc: "bgfx_alloc"   , dynlib: BGFXPath.}
proc copy*(data: pointer, size: uint32): ptr Memory     {.importc: "bgfx_copy"    , dynlib: BGFXPath.}
proc make_ref*(data: pointer, size: uint32): ptr Memory {.importc: "bgfx_make_ref", dynlib: BGFXPath.}
