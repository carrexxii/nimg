from std/strformat import fmt
import common, model, material, animation, texture

type ProcessFlag* = distinct uint32
func `or`*(a, b: ProcessFlag): ProcessFlag {.borrow.}
const
    ProcessCalcTangentSpace*         = 0x0000_0001
    ProcessJoinIdenticalVertices*    = 0x0000_0002
    ProcessMakeLeftHanded*           = 0x0000_0004
    ProcessTriangulate*              = 0x0000_0008
    ProcessRemoveComponent*          = 0x0000_0010
    ProcessGenNormals*               = 0x0000_0020
    ProcessGenSmoothNormals*         = 0x0000_0040
    ProcessSplitLargeMeshes*         = 0x0000_0080
    ProcessPreTransformVertices*     = 0x0000_0100
    ProcessLimitBoneWeights*         = 0x0000_0200
    ProcessValidateDataStructure*    = 0x0000_0400
    ProcessImproveCacheLocality*     = 0x0000_0800
    ProcessRemoveRedundantMaterials* = 0x0000_1000
    ProcessFixInfacingNormals*       = 0x0000_2000
    ProcessPopulateArmatureData*     = 0x0000_4000
    ProcessSortByPType*              = 0x0000_8000
    ProcessFindDegenerates*          = 0x0001_0000
    ProcessFindInvalidData*          = 0x0002_0000
    ProcessGenUVCoords*              = 0x0004_0000
    ProcessTransformUVCoords*        = 0x0008_0000
    ProcessFindInstances*            = 0x0010_0000
    ProcessOptimizeMeshes*           = 0x0020_0000
    ProcessOptimizeGraph*            = 0x0040_0000
    ProcessFlipUVs*                  = 0x0080_0000
    ProcessFlipWindingOrder*         = 0x0100_0000
    ProcessSplitByBoneCount*         = 0x0200_0000
    ProcessDebone*                   = 0x0400_0000
    ProcessGlobalScale*              = 0x0800_0000
    ProcessEmbedTextures*            = 0x1000_0000
    ProcessForceGenNormals*          = 0x2000_0000
    ProcessDropNormals*              = 0x4000_0000
    ProcessGenBoundingBoxes*         = 0x8000_0000

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
    name           : String
    position       : Vec3
    up             : Vec3
    look_at        : Vec3
    horizontal_fov : float32
    clip_plane_near: float32
    clip_plane_far : float32
    aspect         : float32
    ortho_width    : float32

type
    LightSourceKind* = enum
        Undefined
        Directional
        Point
        Spot
        Ambient
        Area
    Light* = object
        name                 : String
        kind                 : LightSourceKind
        position             : Vec3
        direction            : Vec3
        up                   : Vec3
        attenuation_constant : float32
        attenuation_linea    : float32
        attenuation_quadratic: float32
        colour_diffuse       : Colour3
        colour_specular      : Colour3
        colour_ambient       : Colour3
        angle_inner_cone     : float32
        angle_outer_cone     : float32
        size                 : Vec2

type Scene* = object
    flags*         : SceneFlag
    root_node      : ptr Node
    mesh_count     : uint32
    meshes         : ptr UncheckedArray[ptr Mesh]
    material_count : uint32
    materials      : ptr UncheckedArray[ptr Material]
    animation_count: uint32
    animations     : ptr UncheckedArray[ptr Animation]
    texture_count  : uint32
    textures       : ptr UncheckedArray[ptr Texture]
    light_count    : uint32
    lights         : ptr UncheckedArray[ptr Light]
    camera_count   : uint32
    cameras        : ptr UncheckedArray[ptr Camera]
    meta_data      : ptr MetaData
    name           : String
    skeleton_count : uint32
    skeletons      : ptr UncheckedArray[ptr Skeleton]
    private        : pointer

proc import_file(path: cstring; flags: uint32): ptr Scene {.importc: "aiImportFile", dynlib: AIPath.}
proc import_file*(path: string; flags: ProcessFlag): ptr Scene =
    result = import_file(path.cstring, flags.uint32)
    if result == nil:
        echo fmt"Error: failed to load '{path}'"

proc free_scene*(scene: ptr Scene) {.importc: "aiReleaseImport", dynlib: AIPath.}

when is_main_module:
    const file = "gfx/models/fish.glb"
    var scene = import_file(file, ProcessFlag 0)
    echo fmt"Loaded file '{file}'"
    free_scene scene
