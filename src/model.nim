import std/streams
import common
import bgfx/bgfx

type
    OutputFlag* = enum
        VerticesInterleaved
        VerticesSeparated
    OutputMask* {.size: sizeof(uint16).} = set[OutputFlag]

    VertexFlag* = enum
        VertexPosition
        VertexNormal
        VertexTangent
        VertexBitangent
        VertexColourRGBA
        VertexColourRGB
        VertexUV
        VertexUV3
    VertexMask* {.size: sizeof(uint16).} = set[VertexFlag]

    Header* {.packed.} = object
        magic*          : array[4, byte]
        output_flags*   : OutputMask
        vertex_flags*   : VertexMask
        mesh_count*     : uint16
        material_count* : uint16
        animation_count*: uint16
        texture_count*  : uint16
        skeleton_count* : uint16

type Mesh* = object

type Model* = object
    vbo: VBO
    ibo: IBO

proc load*(path: string): Model =
    let file = open_file_stream(path, fmRead)
    var header: Header
    read_data(file, header.addr, sizeof Header)
