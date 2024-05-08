func is_valid*(handle: uint16): bool =
    handle.uint != high uint16

import debug, flags, memory, buffers, shaders, video, init
export debug, flags, memory, buffers, shaders, video, init
