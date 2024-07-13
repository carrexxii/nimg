# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import
    ngm, nsdl, ngfx, ngfx/debug,
    common, model

const
    WinW = 1280
    WinH = 800

echo green &"Nim version: {NimVersion}"
echo green &"SDL version: {sdl_version()}"

nsdl.init ifVideo or ifEvents
let window = create_window("SDL + BGFX", WinW, WinH, wfResizeable)

ngfx.init cast[pointer](get_x11_window_number window), cast[pointer](get_x11_display_pointer window), WinW, WinH
set_debug dfNone
set_view_clear ViewID 0, colour or depth, 0x003535FF, 1.0, 0

model.init()
let mdl = model.load "gfx/models/fish.nai"

let dir = vec(0, 0, 0) - vec(5, 10, 5)
var camera = camera(69, 16/9, 0.1, 100.0, pos = vec(5, 10, 5), dir = dir, up = vec(1, 1, 1))

var mmat = Mat4Ident

var encoder: Encoder
var frame_num: uint32
var running = true
while running:
    for event in get_events():
        case event.kind
        of eQuit: running = false
        of eKeyUp: discard
        of eKeyDown:
            case event.kb.key
            of kcEscape: running = false
            of kcUp   : mmat[3][1] += 0.1
            of kcDown : mmat[3][1] -= 0.1
            of kcRight: mmat[3][0] += 0.1
            of kcLeft : mmat[3][0] -= 0.1
            of kcW: camera.pan Up
            of kcS: camera.pan Down
            of kcA: camera.pan Left
            of kcD: camera.pan Right
            else: discard
        else:
            discard

    update camera
    set_view_transform ViewID 0, camera.view.addr, camera.proj.addr
    set_view_rect ViewID 0, 0, 0, WinW, WinH

    with encoder:
        start
        set_transform mmat.addr
        draw mdl
        stop

    debug.clear()
    debug.print 0, 1, "Hello, World!"
    debug.print 0, 2, &"Total memory usage: {get_total_mem()/1024/1024:.2}MB"
    debug.print 0, 3, &"Frame: {frame_num}"

    frame_num = frame false

ngfx.shutdown()
destroy window
nsdl.quit()

