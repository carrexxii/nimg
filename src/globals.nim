from nsdl import Nanoseconds, fps_to_ns

var
    window_width*  = 1280
    window_height* = 800
    aspect_ratio*  = window_width / window_height
    target_dt*: Nanoseconds = fps_to_ns 60

