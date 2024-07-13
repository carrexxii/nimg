# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import
    std/streams,
    ngfx, ngm,
    common, nai
from std/strutils import join

const ShaderDir = "shaders/bin"

type
    Vertex {.packed.} = object
        pos*   : Vec3
        normal*: Vec3
        uv*    : Vec2

    Mesh = object
        vert_count : uint32
        index_count: uint32
        vbo: VBO
        ibo: IBO

    Model = object
        meshes: seq[Mesh] = new_seq_of_cap[Mesh] 1

var
    program: Program
    layout : VertexLayout

proc init*() =
    program = create_program(ShaderDir / "model.vs.bin", ShaderDir / "model.fs.bin")
    layout = create_vertex_layout((aPosition , 3, akFloat),
                                  (aNormal   , 3, akFloat),
                                  (aTexCoord0, 2, akFloat))

proc load*(path: string): Model =
    let file = path.open_file_stream fmRead

    var header: Header
    file.read header
    let header_errs = validate header

    var read_size: int
    var vert_buf : seq[Vertex]
    var index_buf: seq[uint32] # TODO: size to match mesh_header.index_size
    for _ in 0'u16..<header.mesh_count:
        var mesh_header: MeshHeader
        file.read mesh_header

        vert_buf.set_len  mesh_header.vert_count
        index_buf.set_len mesh_header.index_count

        let vert_size = (int mesh_header.vert_count) * sizeof Vertex
        read_size = file.read_data(vert_buf[0].addr, vert_size)
        if read_size != vert_size:
            error &"Failed to read correct number of vertices, got {read_size}B, expected {vert_size}B"

        let index_size = (int mesh_header.index_count) * mesh_header.index_size
        read_size = file.read_data(index_buf[0].addr, index_size)
        if read_size != index_size:
            error &"Failed to read correct number of indices, got {read_size}B, expected {index_size}B"

        let
            vert_mem  = copy(vert_buf[0].addr , vert_size)
            index_mem = copy(index_buf[0].addr, index_size)
            vbo       = create_vbo(vert_mem, layout)
            ibo       = create_ibo index_mem
        result.meshes.add Mesh(vbo: vbo, vert_count : mesh_header.vert_count,
                               ibo: ibo, index_count: mesh_header.index_count)

    close file

proc draw*(encoder: Encoder; mdl: Model) =
    for mesh in mdl.meshes:
        with encoder:
            set_vbo VertexStream 0, mesh.vbo, 0, mesh.vert_count
            set_ibo mesh.ibo, 0, mesh.index_count
            submit ViewID 0, program

