# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import
    ngm, nsdl, ngfx, ngfx/debug,
    common, globals, models, input

proc quit()

echo green &"Nim version: {NimVersion}"
echo green &"SDL version: {sdl_version()}"

nsdl.init ifVideo or ifEvents
let window = create_window("SDL + BGFX", window_width, window_height, wfResizeable)

ngfx.init cast[pointer](get_x11_window_number window), cast[pointer](get_x11_display_pointer window), window_width, window_height
set_debug dfNone
set_view_clear ViewID 0, colour or depth, 0x003535FF, 1.0, 0

init_models()
let mdl = load_model "gfx/models/fish.nai"

var camera = Camera(
    pos   : vec(5, 10, 5),
    target: vec(0, 0, 0),
    up    : vec(1, 1, 1),
)
camera.set_perspective 69, aspect_ratio, 0.1, 100.0

var mmat = Mat4x4Ident

var cam_dir: CameraDirection

var
    encoder: Encoder
    frame_num: uint32

    dt, nt, ot, acc = 0'ns

var game_events = new_event_map()
proc toggle(dir: CameraDirection; was_up: bool) {.inline.} =
    if not was_up:
        cam_dir = dir
    elif (cam_dir == dir) and was_up:
        cam_dir = cdNone
with game_events:
    register kcEscape, ((_: KeyCode, _: bool) => quit())
    register kcW, ((kc: KeyCode, was_up: bool) => cdForwards.toggle  was_up)
    register kcS, ((kc: KeyCode, was_up: bool) => cdBackwards.toggle was_up)
    register kcA, ((kc: KeyCode, was_up: bool) => cdLeft.toggle      was_up)
    register kcD, ((kc: KeyCode, was_up: bool) => cdRight.toggle     was_up)
    register eMouseMotion, ((delta: Vec2) => camera.move delta)

ot =  get_ticks()
while true:
    if process game_events:
        quit()

    nt = get_ticks()
    dt = nt - ot
    ot = nt
    acc += dt
    while acc >= target_dt:
        acc -= target_dt

        camera.move cam_dir
        update camera

    set_view_transform ViewID 0, camera.view.addr, camera.proj.addr
    set_view_rect ViewID 0, 0, 0, uint16 window_width, uint16 window_height

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

proc quit() {.noreturn.} =
    deinit_models()
    ngfx.shutdown()
    destroy window
    nsdl.quit()
    quit 0

