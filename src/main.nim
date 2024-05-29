import
    nsdl, nbgfx, ngm,
    common, model

const
    WinW = 1280
    WinH = 800

echo green &"Nim version: {NimVersion}"
echo green &"SDL version: {nsdl.get_version()}"

nsdl.init Video or Events
let window = create_window("SDL + BGFX", WinW, WinH, Resizeable)

init(cast[pointer](get_x11_window_number window), cast[pointer](get_x11_display_pointer window), WinW, WinH)
set_debug Text
set_view_clear(ViewID 0, ClearFlag.Colour or ClearFlag.Depth, 0x003535FF, 1.0, 0)

model.init()
let mdl = model.load "gfx/models/fish.nai"

var encoder: Encoder
var frame_num: uint32
var running = true
while running:
    for event in get_events():
        case event.kind
        of Quit: running = false
        of KeyUp: discard
        of KeyDown:
            case event.key.keysym.sym
            of Key_Escape: running = false
            else: discard
        else:
            discard

    set_view_rect(ViewID 0, 0, 0, WinW, WinH)

    encoder.start
    encoder.touch ViewID 0
    encoder.stop

    debug_text_clear(0, false)
    debug_text_printf(0, 1, 0x0f, "Hello, World!")
    debug_text_printf(0, 2, 0x0f, cstring &"Total memory usage: {get_total_mem()/1024/1024:.2}MB")
    debug_text_printf(0, 3, 0x0f, cstring &"Frame: {frame_num}")

    encoder.draw mdl

    frame_num = frame false

#bgfx.shutdown()
destroy window
nsdl.quit()
