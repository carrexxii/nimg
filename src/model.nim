import
    std/streams,
    ngfx, ngm,
    common, naiheader

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
    program = create_program "model"
    layout = create_vertex_layout((Attrib.Position , 3, AttribKind.Float),
                                  (Attrib.Normal   , 3, AttribKind.Float),
                                  (Attrib.TexCoord0, 2, AttribKind.Float))

proc load*(path: string): Model =
    result = Model()
    template read_into(dst, size) =
        if stream.read_data(dst.addr, size) != size:
            let sz {.inject.} = size
            echo red &"Error: failed reading {sz}B/{sz/1024:.2f}kB from '{path}'"

    let stream = open_file_stream(path, fmRead)
    defer: stream.close()

    var
        header     : Header
        vert_buf   : seq[Vertex]
        vert_count : uint32
        index_buf  : seq[uint32]
        index_count: uint32
    read_into(header, sizeof Header)
    for i in 0'u16..<header.mesh_count:
        read_into(vert_count , sizeof vert_count)
        read_into(index_count, sizeof index_count)
        if vert_buf.capacity  < int vert_count : vert_buf.set_len  vert_count
        if index_buf.capacity < int index_count: index_buf.set_len index_count

        let vert_mem_size  = (int vert_count)  * sizeof Vertex
        let index_mem_size = (int index_count) * sizeof uint32
        read_into(vert_buf[0] , vert_mem_size)
        read_into(index_buf[0], index_mem_size)

        let vert_mem  = copy(vert_buf[0].addr , vert_mem_size)
        let index_mem = copy(index_buf[0].addr, index_mem_size)
        let vbo = create_vbo(vert_mem, layout)
        let ibo = create_ibo index_mem
        result.meshes.add Mesh(vbo: vbo, vert_count : vert_count,
                               ibo: ibo, index_count: index_count)

proc draw*(e: Encoder; mdl: Model) =
    for mesh in mdl.meshes:
        e.set_vbo(VertexStream 0, mesh.vbo, 0, mesh.vert_count)
        e.set_ibo(mesh.ibo, 0, mesh.index_count)
        e.submit(ViewID 0, program)
