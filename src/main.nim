# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import
    ngm, nsdl, ngfx, ngfx/debug,
    common, config, models

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

init_models()
let mdl = load_model "gfx/models/fish.nai"

var camera = Camera(
    pos   : vec(5, 10, 5),
    target: vec(0, 0, 0),
    up    : vec(1, 1, 1),
)
camera.set_perspective 69, 16/9, 0.1, 100.0

var mmat = Mat4x4Ident

var cam_dir: CameraDirection

var
    encoder: Encoder
    frame_num: uint32
    running = true

    dt, nt, ot, acc = 0'ns
ot =  get_ticks()
while running:
    for event in get_events():
        case event.kind
        of eQuit: running = false
        of eKeyDown:
            case event.kb.key
            of kcEscape: running = false
            of kcW    : cam_dir = cdForwards
            of kcS    : cam_dir = cdBackwards
            of kcA    : cam_dir = cdLeft
            of kcD    : cam_dir = cdRight
            of kcSpace: cam_dir = cdUp
            of kcLCtrl: cam_dir = cdDown
            else: discard
        of eKeyUp:
            case event.kb.key
            of kcW    : cam_dir = (if cam_dir == cdForwards : cdNone else: cam_dir)
            of kcS    : cam_dir = (if cam_dir == cdBackwards: cdNone else: cam_dir)
            of kcA    : cam_dir = (if cam_dir == cdLeft     : cdNone else: cam_dir)
            of kcD    : cam_dir = (if cam_dir == cdRight    : cdNone else: cam_dir)
            of kcSpace: cam_dir = (if cam_dir == cdUp       : cdNone else: cam_dir)
            of kcLCtrl: cam_dir = (if cam_dir == cdDown     : cdNone else: cam_dir)
            else: discard
        of eMouseMotion:
            camera.move vec(event.motion.x_rel, event.motion.y_rel)
        else:
            discard

    nt = get_ticks()
    dt = nt - ot
    ot = nt
    acc += dt
    while acc >= target_dt:
        acc -= target_dt

        camera.move cam_dir
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

deinit_models()
ngfx.shutdown()
destroy window
nsdl.quit()

