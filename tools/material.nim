import common

type
    TextureOp* = enum
        Multiply
        Add
        Subtract
        Divide
        SmoothAdd
        SignedAdd

    TextureMapOp* = enum
        Wrap
        Clamp
        Mirror
        Decal

    TextureMapping* = enum
        UV
        Sphere
        Cylinder
        Box
        Plane
        Other

    TextureKind* = enum
        None
        Diffuse
        Specular
        Ambient
        Emissive
        Height
        Normals
        Shininess
        Opacity
        Displacement
        Lightmap
        Reflection
        BaseColour
        NormalCamera
        EmissionColour
        Metalness
        DiffuseRoughness
        AmbientOcclusion
        Unknown
        Sheen
        Clearcoat
        Transmission

    ShadingMode* = enum
        Flat
        Gouraud
        Phong
        Blinn
        Toon
        OrenNayar
        Minnaert
        CookTorrance
        NoShading
        Fresnel
        PBRBRDF

    BlendMode* = enum
        Default
        Additive

    PropertyKindInfo* = enum
        Float
        Double
        String
        Integer
        Buffer

const Unlit* = NoShading

type TextureFlag* = distinct uint32
func `or`*(a, b: TextureFlag): TextureFlag {.borrow.}
const
    TextureInvert*      = 0x1
    TextureUseAlpha*    = 0x2
    TextureIgnoreAlpha* = 0x4

type
    Material* = object
        properties      : ptr UncheckedArray[ptr MaterialProperty]
        properties_count: uint32
        allocated_count : uint32

    MaterialProperty* = object
        key        : String
        semantic   : uint32
        index      : uint32
        data_length: uint32
        kind       : PropertyKindInfo
        data       : ptr byte

    UVTransform* = object
        translation: Vec2
        scaling    : Vec2
        rotation   : Real

proc `$`*(kind: TextureKind): cstring {.importc: "aiTextureTypeToString", dynlib: AIPath.}
