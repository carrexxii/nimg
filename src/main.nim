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

nsdl.init Video or Events
let window = create_window("SDL + BGFX", WinW, WinH, Resizeable)

init(cast[pointer](get_x11_window_number window), cast[pointer](get_x11_display_pointer window), WinW, WinH)
set_debug Text
set_view_clear(ViewID 0, ClearFlag.Colour or ClearFlag.Depth, 0x003535FF, 1.0, 0)

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
        of Quit: running = false
        of KeyUp: discard
        of KeyDown:
            case event.key.keysym.sym
            of KEscape: running = false
            of KUp   : mmat[3][1] += 0.1
            of KDown : mmat[3][1] -= 0.1
            of KRight: mmat[3][0] += 0.1
            of KLeft : mmat[3][0] -= 0.1
            of Kw: camera.pan Up
            of Ks: camera.pan Down
            of Ka: camera.pan Left
            of Kd: camera.pan Right
            else: discard
        else:
            discard

    update camera
    set_view_transform(ViewID 0, camera.view.addr, camera.proj.addr)
    set_view_rect(ViewID 0, 0, 0, WinW, WinH)

    encoder.start
    encoder.set_transform mmat.addr
    encoder.draw mdl
    encoder.stop

    debug.clear()
    debug.print(0, 1, "Hello, World!")
    debug.print(0, 2, &"Total memory usage: {get_total_mem()/1024/1024:.2}MB")
    debug.print(0, 3, &"Frame: {frame_num}")

    frame_num = frame false

#bgfx.shutdown()
destroy window
nsdl.quit()
