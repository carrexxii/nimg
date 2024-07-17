import std/tables, nsdl, common, globals
from ngm import Vec2, vec

type
    KeyCallbackFn*    = proc(kc: KeyCode; was_up: bool) {.closure.}
    MotionCallbackFn* = proc(delta: Vec2) {.closure.}

    KeyCallback = object
        callback   : KeyCallbackFn
        on_key_down: bool
        on_key_up  : bool

    EventMap = object
        keys  : Table[KeyCode, KeyCallback]
        motion: seq[MotionCallbackFn]

func new_event_map*(): EventMap =
    result.keys   = init_table[KeyCode, KeyCallback] 64
    result.motion = new_seq_of_cap[MotionCallbackFn] 4

proc process*(map: EventMap): bool =
    result = false
    for event in get_events():
        case event.kind
        of eQuit: return true
        of eKeyDown, eKeyUp:
            let kc = event.kb.key
            if map.keys.has_key kc:
                let cb = map.keys[kc]
                if ((event.kind == eKeyDown) and cb.on_key_down) or
                   ((event.kind == eKeyUp)   and cb.on_key_up):
                    cb.callback kc, (event.kind == eKeyUp)
        of eMouseMotion:
            let delta = vec(event.motion.x_rel / aspect_ratio,
                            event.motion.y_rel / aspect_ratio)
            for cb in map.motion:
                cb delta
        else:
            discard

proc register*(map: var EventMap; kc: KeyCode; cb: KeyCallbackFn; on_key_down, on_key_up = true) =
    map.keys[kc] = KeyCallback(
        callback   : cb,
        on_key_up  : on_key_up,
        on_key_down: on_key_down,
    )

proc register*(map: var EventMap; kind: EventKind; cb: MotionCallbackFn) =
    if kind != eMouseMotion:
        error &"Mismatched kind for callback, expected: '{eMouseMotion}', got: '{kind}'"
    map.motion.add cb

