from std/strformat import fmt

const AIPath = "./tools/libassimp.so"

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

type Scene = object

proc import_file(path: cstring; flags: cuint): ptr Scene {.importc: "aiImportFile", dynlib: AIPath.}
proc import_file*(path: string; flags: ProcessFlag): ptr Scene =
    result = import_file(path.cstring, flags.cuint)
    if result == nil:
        echo fmt"Error: failed to load '{path}'"

proc free_scene*(scene: ptr Scene) {.importc: "aiReleaseImport", dynlib: AIPath.}

when is_main_module:
    echo "Testing NAI..."
    var scene = import_file("gfx/models/fish.glb", ProcessFlag 0)
    free_scene scene
