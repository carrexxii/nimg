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

    Material = object
        diffuse: Texture

    Mesh = object
        vert_count : uint32
        index_count: uint32
        vbo        : VBO
        ibo        : IBO
        mtl_index  : int

    Model = object
        meshes   : seq[Mesh]
        materials: seq[Material]

var
    program : Program
    layout  : VertexLayout
    uniforms: tuple[
        diffuse: Uniform
    ]

proc init_models*() =
    program = create_program(ShaderDir / "model.vs.bin", ShaderDir / "model.fs.bin")
    layout = create_vertex_layout((aPosition , 3, akFloat),
                                  (aNormal   , 3, akFloat),
                                  (aTexCoord0, 2, akFloat))
    uniforms.diffuse = create_uniform("diffuse_tex", ukSampler)

proc load_model*(path: string): Model =
    let file = path.open_file_stream fmRead
    proc read(dst: pointer; size: int; name: string) =
        let read_size = file.read_data(dst, size)
        if read_size != size:
            error &"Failed to read correct number of bytes from '{path}' for '{name}'\n" &
                  &"    got {bytes_to_string read_size}, expected {bytes_to_string size}"

    var header: Header
    file.read header
    let header_errs = validate(header, [])
    if header_errs != @[]:
        error header_errs.join "\n"

    result = Model(
        meshes   : new_seq_of_cap[Mesh] header.mesh_count,
        materials: new_seq_of_cap[Material] header.material_count,
    )

    var read_size: int
    var vert_buf : seq[Vertex]
    var index_buf: seq[uint32] # TODO: size to match mesh_header.index_size
    for i in 0'u16..<header.mesh_count:
        var mesh_header: MeshHeader
        file.read mesh_header

        vert_buf.set_len  mesh_header.vert_count
        index_buf.set_len mesh_header.index_count

        let vert_size  = (int mesh_header.vert_count) * sizeof Vertex
        let index_size = (int mesh_header.index_count) * mesh_header.index_size
        read vert_buf[0].addr , vert_size , &"Mesh {i} vertices"
        read index_buf[0].addr, index_size, &"Mesh {i} indices"

        let
            vert_mem  = copy(vert_buf[0].addr , vert_size)
            index_mem = copy(index_buf[0].addr, index_size)
            vbo       = create_vbo(vert_mem, layout)
            ibo       = create_ibo index_mem
        result.meshes.add Mesh(vbo: vbo, vert_count : mesh_header.vert_count,
                               ibo: ibo, index_count: mesh_header.index_count,
                               mtl_index: int mesh_header.material_index)

    for i in 0'u16..<header.material_count:
        var mtl_header: MaterialHeader
        file.read mtl_header
        echo mtl_header
        for j in 0'u16..<mtl_header.texture_count:
            var tex_header: TextureHeader
            file.read tex_header

            var tex_data = alloc tex_header.size
            read tex_data, tex_header.size, &"Texture data (texture {j}; material {i})"
            result.materials.add Material(
                diffuse: create_texture(tex_data, tex_header.format, tex_header.w, tex_header.h)
            )

    close file

proc draw*(encoder: Encoder; mdl: Model) =
    for mesh in mdl.meshes:
        let diffuse = mdl.materials[mesh.mtl_index].diffuse
        with encoder:
            set_vbo VertexStream 0, mesh.vbo, 0, mesh.vert_count
            set_ibo mesh.ibo, 0, mesh.index_count
            set_texture uniforms.diffuse, diffuse
            submit ViewID 0, program

proc deinit_models*() =
    for uniform in uniforms.fields:
        destroy uniform
    destroy program

