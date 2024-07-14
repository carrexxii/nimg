import nai, ngfx
from std/strformat import `&`

converter `nai texture format -> ngfx texture format`*(fmt: nai.TextureFormat): ngfx.TextureFormat =
    case fmt
    of tfR   : tfR8
    of tfRG  : tfRG8
    of tfRGB : tfRGB8
    of tfRGBA: tfRGBA8
    of tfBC1 : tfBC1
    of tfBC3 : tfBC3
    of tfBC4 : tfBC4
    of tfBC5 : tfBC5
    of tfBC6H: tfBC6H
    of tfBC7 : tfBC7
    of tfETC1: tfETC1
    of tfASTC4x4: tfASTC4X4
    else:
        echo &"Cannot convert {fmt} to NGFX texture format"
        quit 1

