import std/strformat
import cglm/cglm
import sdl/sdl
import bgfx/bgfx
import debug

const
    WinW = 1280
    WinH = 800

echo green fmt"Nim version: {NimVersion}"
echo green fmt"SDL version: {sdl.get_version()}"

init(VideoFlag, EventsFlag)
let window = sdl.create_window("SDL + BGFX", WinW, WinH, sdl.WindowResizable)

init(window, WinW, WinH)
set_debug DebugText
set_view_clear(ViewID 0, ClearColour or ClearDepth, 0x003535FF, 1.0, 0)

type
    Colour = distinct uint32
    Vertex = object
        pos   : Vec3
        colour: Colour

var verts = [
    Vertex(pos: Vec3(x:  0.0, y:  1.0, z: 0.0), colour: Colour 0xFFFF0000),
    Vertex(pos: Vec3(x: -1.0, y: -1.0, z: 0.0), colour: Colour 0xFF00FF00),
    Vertex(pos: Vec3(x:  1.0, y: -1.0, z: 0.0), colour: Colour 0xFF0000FF),
]
var vert_mem = copy(verts[0].addr, 3*sizeof(Vertex))

var program = create_program "model"
var layout = create_vbo_layout [(Position, 3, Float), (Colour0, 4, UInt8)]
var vbo = create_vbo(vert_mem, layout.addr, BufferNone)

var encoder: Encoder
var frame_num: uint32
var running = true
while running:
    for event in get_event():
        case event.kind
        of Quit: running = false
        of KeyUp: discard
        of KeyDown:
            case event.key.keysym.sym
            of Key_Escape: running = false
            else: discard

    set_view_rect(ViewID 0, 0, 0, WinW, WinH)

    encoder = begin_encoder false
    touch(encoder, ViewID 0)
    end_encoder encoder

    debug_text_clear(0, false)
    debug_text_printf(0, 1, 0x0f, "Hello, World!")
    debug_text_printf(0, 2, 0x0f, cstring fmt"Total memory usage: {get_total_mem()/1024/1024:.2}MB")
    debug_text_printf(0, 3, 0x0f, cstring fmt"Frame: {frame_num}")

    set_vbo(VBOStream 0, vbo, 0, 3)
    set_state StateDefault
    submit(ViewID 0, program)

    frame_num = submit_frame false

bgfx.shutdown()
close_window window
sdl.quit()
