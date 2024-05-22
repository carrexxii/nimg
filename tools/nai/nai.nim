import std/[streams, macros]
from std/sequtils import zip
from std/strutils import split
from std/strformat import fmt
import common, mesh, material, animation, texture
export common, mesh, material, animation, texture

type ProcessFlag* = distinct uint32
func `or`*(a, b: ProcessFlag): ProcessFlag {.borrow.}
const
    ProcessCalcTangentSpace*         = ProcessFlag 0x0000_0001
    ProcessJoinIdenticalVertices*    = ProcessFlag 0x0000_0002
    ProcessMakeLeftHanded*           = ProcessFlag 0x0000_0004
    ProcessTriangulate*              = ProcessFlag 0x0000_0008
    ProcessRemoveComponent*          = ProcessFlag 0x0000_0010
    ProcessGenNormals*               = ProcessFlag 0x0000_0020
    ProcessGenSmoothNormals*         = ProcessFlag 0x0000_0040
    ProcessSplitLargeMeshes*         = ProcessFlag 0x0000_0080
    ProcessPreTransformVertices*     = ProcessFlag 0x0000_0100
    ProcessLimitBoneWeights*         = ProcessFlag 0x0000_0200
    ProcessValidateDataStructure*    = ProcessFlag 0x0000_0400
    ProcessImproveCacheLocality*     = ProcessFlag 0x0000_0800
    ProcessRemoveRedundantMaterials* = ProcessFlag 0x0000_1000
    ProcessFixInfacingNormals*       = ProcessFlag 0x0000_2000
    ProcessPopulateArmatureData*     = ProcessFlag 0x0000_4000
    ProcessSortByPType*              = ProcessFlag 0x0000_8000
    ProcessFindDegenerates*          = ProcessFlag 0x0001_0000
    ProcessFindInvalidData*          = ProcessFlag 0x0002_0000
    ProcessGenUVCoords*              = ProcessFlag 0x0004_0000
    ProcessTransformUVCoords*        = ProcessFlag 0x0008_0000
    ProcessFindInstances*            = ProcessFlag 0x0010_0000
    ProcessOptimizeMeshes*           = ProcessFlag 0x0020_0000
    ProcessOptimizeGraph*            = ProcessFlag 0x0040_0000
    ProcessFlipUVs*                  = ProcessFlag 0x0080_0000
    ProcessFlipWindingOrder*         = ProcessFlag 0x0100_0000
    ProcessSplitByBoneCount*         = ProcessFlag 0x0200_0000
    ProcessDebone*                   = ProcessFlag 0x0400_0000
    ProcessGlobalScale*              = ProcessFlag 0x0800_0000
    ProcessEmbedTextures*            = ProcessFlag 0x1000_0000
    ProcessForceGenNormals*          = ProcessFlag 0x2000_0000
    ProcessDropNormals*              = ProcessFlag 0x4000_0000
    ProcessGenBoundingBoxes*         = ProcessFlag 0x8000_0000

type SceneFlag* = distinct uint32
func `or`*(a, b: SceneFlag): SceneFlag {.borrow.}
const
    SceneIncomplete*        = 0x01
    SceneValidated*         = 0x02
    SceneValidationWarning* = 0x04
    SceneNonVerboseFormat*  = 0x08
    SceneTerrain*           = 0x10
    SceneAllowShared*       = 0x20

type Camera* = object
    name*           : String
    position*       : Vec3
    up*             : Vec3
    look_at*        : Vec3
    horizontal_fov* : float32
    clip_plane_near*: float32
    clip_plane_far* : float32
    aspect*         : float32
    ortho_width*    : float32

type
    LightSourceKind* = enum
        Undefined
        Directional
        Point
        Spot
        Ambient
        Area
    Light* = object
        name*                 : String
        kind*                 : LightSourceKind
        position*             : Vec3
        direction*            : Vec3
        up*                   : Vec3
        attenuation_constant* : float32
        attenuation_linea*    : float32
        attenuation_quadratic*: float32
        colour_diffuse*       : Colour3
        colour_specular*      : Colour3
        colour_ambient*       : Colour3
        angle_inner_cone*     : float32
        angle_outer_cone*     : float32
        size*                 : Vec2

type Scene* = object
    flags*          : SceneFlag
    root_node*      : ptr Node
    mesh_count*     : uint32
    meshes*         : ptr UncheckedArray[ptr Mesh]
    material_count* : uint32
    materials*      : ptr UncheckedArray[ptr Material]
    animation_count*: uint32
    animations*     : ptr UncheckedArray[ptr Animation]
    texture_count*  : uint32
    textures*       : ptr UncheckedArray[ptr Texture]
    light_count*    : uint32
    lights*         : ptr UncheckedArray[ptr Light]
    camera_count*   : uint32
    cameras*        : ptr UncheckedArray[ptr Camera]
    meta_data*      : ptr MetaData
    name*           : String
    skeleton_count* : uint32
    skeletons*      : ptr UncheckedArray[ptr Skeleton]
    private         : pointer

# TODO: import_file interface for memory load
#       property imports
# proc import_file*(buffer: ptr byte; length: uint32; flags: uint32; hint: cstring): ptr Scene {.importc: "aiImportFileFromMemory", dynlib: AIPath.}
proc get_error*(): cstring                                     {.importc: "aiGetErrorString"      , dynlib: AIPath.}
proc is_extension_supported*(ext: cstring): bool               {.importc: "aiIsExtensionSupported", dynlib: AIPath.}
proc get_extension_list(lst: ptr String)                       {.importc: "aiGetExtensionList"    , dynlib: AIPath.}
proc import_file(path: cstring; flags: uint32): ptr Scene      {.importc: "aiImportFile", dynlib: AIPath.}
proc process*(scene: ptr Scene; flags: ProcessFlag): ptr Scene {.importc: "aiApplyPostProcessing" , dynlib: AIPath.}
proc free_scene*(scene: ptr Scene)                             {.importc: "aiReleaseImport"       , dynlib: AIPath.}

proc import_file*(path: string; flags: ProcessFlag): ptr Scene =
    result = import_file(path.cstring, flags.uint32)
    if result == nil:
        echo fmt"Error: failed to load '{path}'"
        quit 1

proc get_extension_list*(): seq[string] =
    var lst: String
    get_extension_list lst.addr
    result = split($lst, ';')

#[ -------------------------------------------------------------------- ]#

proc validate*(scene: ptr Scene; output_errs: bool): int =
    proc check(val: uint; name: string): int =
        result = if val != 0: 1 else: 0
        if val != 0 and output_errs:
            echo yellow fmt"Warning: scene contains {val} {name} which are not supported"

    result =
        check(scene.texture_count  , "textures")   +
        check(scene.material_count , "materials")  +
        check(scene.animation_count, "animations") +
        check(scene.skeleton_count , "skeletons")  +
        check(scene.light_count    , "lights")     +
        check(scene.camera_count   , "cameras")

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

const output_flags = OutputMask {VerticesInterleaved}
const vertex_flags = VertexMask {VertexPosition, VertexNormal, VertexUV}

macro build_vertex() =
    let pack_pragma = newNimNode(nnkPragma)
    let type_name   = newNimNode nnkPragmaExpr
    pack_pragma.add(ident "packed")
    type_name.add(ident "Vertex", pack_pragma)

    var
        type_sec = newNimNode nnkTypeSection
        type_def = newNimNode nnkTypeDef
        obj_def  = newNimNode nnkObjectTy
        fields   = newNimNode nnkRecList
        def : NimNode
        name: string
        kind: string
    for flag in vertex_flags:
        case flag
        of VertexPosition  : name = "pos"      ; kind = "Vec3"
        of VertexNormal    : name = "normal"   ; kind = "Vec3"
        of VertexTangent   : name = "tangent"  ; kind = "Vec3"
        of VertexBitangent : name = "bitangent"; kind = "Vec3"
        of VertexColourRGBA: name = "colour"   ; kind = "Colour"
        of VertexColourRGB : name = "colour"   ; kind = "Colour3"
        of VertexUV        : name = "uv"       ; kind = "Vec2"
        of VertexUV3       : name = "uv"       ; kind = "Vec3"

        def = newNimNode(nnkPostFix)
        def.add(ident "*")
        def.add(ident name)
        fields.add newIdentDefs(def, ident kind)

    obj_def.add(newEmptyNode(), newEmptyNode(), fields)
    type_def.add(type_name, newEmptyNode(), obj_def)
    type_sec.add type_def

    result = newNimNode nnkStmtList
    result.add type_sec

build_vertex()

type Header {.packed.} = object
    magic          : array[4, byte]
    output_flags   : OutputMask
    vertex_flags   : VertexMask
    mesh_count     : uint16
    material_count : uint16
    animation_count: uint16
    texture_count  : uint16
    skeleton_count : uint16

# TODO: ensure flags don't overlap/have invalid pairs
proc write_header*(scene: ptr Scene; file: Stream) =
    var header = Header(
        magic          : [78, 65, 73, 126],
        output_flags   : output_flags,
        vertex_flags   : vertex_flags,
        mesh_count     : uint16 scene.mesh_count,
        material_count : uint16 scene.material_count,
        animation_count: uint16 scene.animation_count,
        texture_count  : uint16 scene.texture_count,
        skeleton_count : uint16 scene.skeleton_count,
    )
    file.write_data(header.addr, sizeof header)

proc write_meshes*(scene: ptr Scene; file: Stream; verbose: bool) =
    template write(flags, dst, src) =
        when flags < vertex_flags:
            dst = src

    if scene.mesh_count != 1:
        assert(false, "Need to implement multiple meshes")
    for mesh in to_open_array(scene.meshes, 0, scene.mesh_count.int - 1):
        if verbose:
            echo fmt"Mesh '{mesh.name}' (material index: {mesh.material_index}) {vertex_flags}"
            echo fmt"    {mesh.vertex_count} vertices ({mesh.face_count} faces)"
            echo fmt"    {mesh.bone_count} bones"
            echo fmt"    {mesh.anim_mesh_count} animation meshes (morphing method: {mesh.morph_method})"
            echo fmt"    AABB: {mesh.aabb}"

        if mesh.primitive_kinds != PrimitiveTriangle:
            echo "Error: mesh contains non-triangle primitives"
            return

        let vc = mesh.vertex_count.int - 1
        when VerticesInterleaved in output_flags:
            var vertex: Vertex
            for i, (pos, normal) in zip(to_open_array(mesh.vertices, 0, vc),
                                        to_open_array(mesh.normals , 0, vc)):
                write({VertexPosition}                   , vertex.pos      , pos)
                write({VertexNormal}                     , vertex.normal   , normal)
                write({VertexTangent}                    , vertex.tangent  , tangent)
                write({VertexBitangent}                  , vertex.bitangent, bitangent)
                write({VertexColourRGBA, VertexColourRGB}, vertex.colour   , colour)
                write({VertexUV, VertexUV3}              , vertex.uv       , uv)
                file.write_data(vertex.addr, sizeof vertex)
        elif VerticesSeparated in output_flags:
            assert false
