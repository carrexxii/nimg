import common
import init
from shaders import ProgramHandle

proc set_view_clear*(view_id: ViewID, flags: ClearFlag, colour: uint32, depth: float32, stencil: byte) {.importc: "bgfx_set_view_clear", dynlib: BGFXPath.}
proc set_view_rect*(view_id: ViewID, x, y, w, h: uint16) {.importc: "bgfx_set_view_rect", dynlib: BGFXPath.}

proc submit_frame*(capture: bool): uint32 {.importc: "bgfx_frame", dynlib: BGFXPath.}

type Encoder* = distinct pointer
proc begin_encoder*(for_thread: bool): Encoder {.importc: "bgfx_encoder_begin", dynlib: BGFXPath.}
proc touch*(encoder: Encoder, view_id: ViewID) {.importc: "bgfx_encoder_touch", dynlib: BGFXPath.}
proc end_encoder*(encoder: Encoder)            {.importc: "bgfx_encoder_end"  , dynlib: BGFXPath.}

proc set_state*(state: StateFlag, colour: uint32) {.importc: "bgfx_set_state", dynlib: BGFXPath.}
proc set_state*(state: StateFlag) =
    set_state(state, high uint32)

proc submit*(view_id: ViewID; program: ProgramHandle; depth: uint32; flags: DiscardFlag) {.importc: "bgfx_submit", dynlib: BGFXPath.}
proc submit*(view_id: ViewID; program: ProgramHandle) =
    submit(view_id, program, 0, DiscardAll)
