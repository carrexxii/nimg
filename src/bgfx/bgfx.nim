func is_valid*(handle: uint16): bool =
    handle.uint != high uint16

import debug, flags, memory, buffer, shader, encoder, init
export debug, flags, memory, buffer, shader, encoder, init
