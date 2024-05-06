import std/options
import sdl/sdl
import bgfx

echo sdl.get_version()
sdl.init(VideoFlag, EventsFlag)
let window = sdl.create_window("SDL + BGFX", 1280, 800, sdl.WindowVulkan or sdl.WindowResizable)

proc exit() {.noreturn.} =
    close_window window
    quit 0

while true:
    for event in get_event():
        case event.kind
        of Quit: exit()
        of KeyUp: discard
        of KeyDown:
            case event.key.keysym.sym
            of Key_Escape: exit()
            else: discard