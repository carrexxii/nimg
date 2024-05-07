import ../debug

const LibPath* = "lib/libSDL3.so"

proc get_error(): cstring {.importc: "SDL_GetError", dynlib: LibPath.}

type Version* = object
    major*: byte
    minor*: byte
    patch*: byte

type InitFlag* = distinct uint32
const
    TimerFlag*    = InitFlag 0x0000_0001
    AudioFlag*    = InitFlag 0x0000_0010
    VideoFlag*    = InitFlag 0x0000_0020
    JoystickFlag* = InitFlag 0x0000_0200
    HapticFlag*   = InitFlag 0x0000_1000
    GamepadFlag*  = InitFlag 0x0000_2000
    EventsFlag*   = InitFlag 0x0000_4000
    SensorFlag*   = InitFlag 0x0000_8000
    CameraFlag*   = InitFlag 0x0001_0000
func `or`*(a, b: InitFlag): InitFlag {.borrow.}

proc init(flags: cuint): cint {.importc: "SDL_Init", dynlib: LibPath.}
proc init*(flags: varargs[InitFlag]) =
    var mask = InitFlag 0
    for flag in flags:
        mask = mask or flag

    if init(cuint mask) != 0:
        echo red "Error: failed to initialize SDL (SDL_Init): " & $get_error()

proc get_version(version: ptr[Version]) {.importc: "SDL_GetVersion", dynlib: LibPath.}
proc get_version*(): Version =
    get_version(addr result)

#[ -------------------------------------------------------------------- ]#

type DisplayID*  = distinct uint32
type WindowID*   = distinct uint32
type KeyboardID* = distinct uint32

type Window* = pointer
type WindowFlag* = distinct uint32
const
    WindowFullscreen*       = WindowFlag 0x0000_0001
    WindowOpenGL*           = WindowFlag 0x0000_0002
    WindowOccluded*         = WindowFlag 0x0000_0004
    WindowHidden*           = WindowFlag 0x0000_0008
    WindowBorderless*       = WindowFlag 0x0000_0010
    WindowResizable*        = WindowFlag 0x0000_0020
    WindowMinimized*        = WindowFlag 0x0000_0040
    WindowMaximized*        = WindowFlag 0x0000_0080
    WindowMouseGrabbed*     = WindowFlag 0x0000_0100
    WindowinputFocus*       = WindowFlag 0x0000_0200
    WindowMouseFocus*       = WindowFlag 0x0000_0400
    WindowExternal*         = WindowFlag 0x0000_0800
    WindowHighPixelDensity* = WindowFlag 0x0000_2000
    WindowMouseCapture*     = WindowFlag 0x0000_4000
    WindowAlwaysOnTop*      = WindowFlag 0x0000_8000
    WindowSkipTaskbar*      = WindowFlag 0x0001_0000
    WindowUtility*          = WindowFlag 0x0002_0000
    WindowTooltip*          = WindowFlag 0x0004_0000
    WindowPopupMenu*        = WindowFlag 0x0008_0000
    WindowKeyboardGrabbed*  = WindowFlag 0x0010_0000
    WindowVulkan*           = WindowFlag 0x1000_0000
    WindowMetal*            = WindowFlag 0x2000_0000
    WindowTransparent*      = WindowFlag 0x4000_0000
    WindowNotFocusable*     = WindowFlag 0x8000_0000
func `or`*(a, b: WindowFlag): WindowFlag {.borrow.}

proc create_window(title: cstring, w, h: cint, flags: WindowFlag): Window {.importc: "SDL_CreateWindow", dynlib: LibPath.}
proc create_window*(title: string, w, h: int, flags: WindowFlag): Window =
    result = create_window(cstring title, cint w, cint h, flags)
    if result == nil:
        echo red "Error: failed to open window (SDL_CreateWindow): " & $get_error()

proc close_window*(window: Window) {.importc: "SDL_DestroyWindow", dynlib: LibPath.}

#[ -------------------------------------------------------------------- ]#

import events
import properties

export events
export properties
