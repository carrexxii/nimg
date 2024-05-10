const NoArmaturePopulateProcess* = true

const AIPath* = "./tools/libassimp.so"

const
    MaxStringLen*     = 1024
    MaxColourSets*    = 0x8
    MaxTextureCoords* = 0x8

type PrimitiveFlag* = distinct uint32
func `or`*(a, b: PrimitiveFlag): PrimitiveFlag {.borrow.}
const
    PrimitivePoint*            = 0x01
    PrimitiveLine*             = 0x02
    PrimitiveTriangle*         = 0x04
    PrimitivePolygon*          = 0x08
    PrimitiveNGonEncodingFlag* = 0x10

type
    Real* = float64

    String* = object
        len : uint32
        data: array[MaxStringLen, char]

    Vec2* = object
        x, y: Real
    Vec3* = object
        x, y, z: Real
    Quat* = object
        w, x, y, z: Real
    Colour* = object
        r, g, b, a: Real
    Colour3* = object
        r, g, b: Real

    Mat4x4* = object
        a1, a2, a3, a4: Real
        b1, b2, b3, b4: Real
        c1, c2, c3, c4: Real
        d1, d2, d3, d4: Real

    AABB* = object
        min: Vec3
        max: Vec3

    MetaDataKind* {.importc: "enum".} = enum
        MDBool
        MDInt32
        MDUInt64
        MDFloat
        MDDouble
        MDString
        MDVec3
        MDMetaData
        MDInt64
        MDUInt32
    MetaDataEntry* = object
        kind: MetaDataKind
        data: pointer
    MetaData* = object
        properties_count: uint32
        keys            : ptr UncheckedArray[String]
        values          : ptr UncheckedArray[MetaDataEntry]

    Node* = object
        name          : String
        transform     : Mat4x4
        parent        : ptr Node
        children_count: uint32
        children      : ptr UncheckedArray[ptr Node]
        mesh_count    : uint32
        meshes        : ptr uint32
        meta_data     : MetaData
