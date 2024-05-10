import common

type
    Mesh* = object
        primitive_kinds    : PrimitiveFlag
        vertices_count     : uint32
        faces_count        : uint32
        vertices           : ptr Vec3
        normals            : ptr Vec3
        tangents           : ptr Vec3
        bitangents         : ptr Vec3
        colours            : ptr array[MaxColourSets, Colour]
        texture_coords     : ptr array[MaxTextureCoords, Vec3]
        uv_component_count : array[MaxTextureCoords, uint32]
        faces              : ptr Face
        bones_count        : uint32
        bones              : ptr UncheckedArray[ptr Bone]
        material_index     : uint32
        name               : String
        anim_mesh_count    : uint32
        anim_meshes        : ptr UncheckedArray[ptr AnimMesh]
        morph_method       : MorphingMethod
        aabb               : AABB
        texture_coord_names: ptr UncheckedArray[ptr String]

    AnimMesh* = object
        name          : String
        vertices      : ptr UncheckedArray[Vec3]
        normals       : ptr UncheckedArray[Vec3]
        tangents      : ptr UncheckedArray[Vec3]
        bitangents    : ptr UncheckedArray[Vec3]
        colours       : array[MaxColourSets, ptr UncheckedArray[Colour]]
        texture_coords: array[MaxTextureCoords, ptr UncheckedArray[Vec3]]
        vertices_count: uint32
        weight        : float32

    MorphingMethod* = enum
        Unknown
        VertexBlend
        MorphNormalized
        MorphRelative

    VertexWeight* = object
        id    : uint32
        weight: Real

    Bone* = object
        parent  : int32
        when NoArmaturePopulateProcess:
            armature: ptr Node
            node    : ptr Node
        weight_count: uint32
        mesh_index  : ptr Mesh
        weights     : ptr UncheckedArray[VertexWeight]
        offset_mat  : Mat4x4
        local_mat   : Mat4x4

    Skeleton* = object
        name: String
        bones_count: uint32
        bones      : ptr UncheckedArray[ptr Bone]

    Face* = object
        indices_count: uint32
        indices      : ptr UncheckedArray[uint32]
