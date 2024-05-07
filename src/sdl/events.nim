import sdl
import scancode
import keycode

export keycode

type Keysym = object
    scancode*: Scancode
    sym*     : Keycode
    modifier*: uint16
    _        : uint32

type
    Event* {.union, bycopy, size: sizeof(128).} = object
        kind*: EventKind
        key* : KeyboardEvent
        quit*: QuitEvent

    QuitEvent* = object
        kind*: EventKind
        time*: uint32

    KeyboardEvent* = object
        kind*     : EventKind
        reserved  : uint32
        time*     : uint64
        window_id*: WindowID
        which*    : KeyboardID
        state*    : byte
        repeat*   : byte
        _         : uint16
        keysym*   : Keysym

    EventState* = enum
        Released = 0
        Pressed  = 1

    EventKind* {.size: sizeof(uint32).} = enum
        Quit    = 0x0100
        KeyDown = 0x0300
        KeyUp

proc get_event(event: ptr Event): bool {.importc: "SDL_PollEvent", dynlib: LibPath.}
iterator get_event*(): Event {.inline.} =
    var event: Event
    while get_event(addr event):
        yield event
