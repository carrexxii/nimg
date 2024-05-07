import sdl/sdl
import bgfx/bgfx

const
    WinW = 1280
    WinH = 800

echo sdl.get_version()
sdl.init(VideoFlag, EventsFlag)
let window = sdl.create_window("SDL + BGFX", WinW, WinH, sdl.WindowResizable)

bgfx.init(window, WinW, WinH)
set_debug(DebugText)
set_view_clear(ViewID 0, ClearColour or ClearDepth, 0x005050FF, 1.0, 0)

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

    var encoder = encoder_begin false
    encoder_touch(encoder, ViewID 0)
    encoder_end encoder

    debug_text_clear(0, false)
    debug_text_printf(0, 1, 0x0f, "Hello, World!")

    discard next_frame(false)

bgfx.shutdown()
close_window window
sdl.quit()
