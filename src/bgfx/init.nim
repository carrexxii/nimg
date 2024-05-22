from std/sugar     import `->`
from std/strformat import fmt
import common
import debug
import nsdl

# PCI Adapters
type VendorID {.size: sizeof(uint16).} = enum
    None      = 0x0000_0000
    Software  = 0x0000_0001
    AMD       = 0x0000_1002
    Apple     = 0x0000_106b
    Nvidia    = 0x0000_10DE
    ARM       = 0x0000_13B5
    Microsoft = 0x0000_1414
    Intel     = 0x0000_8086

type RendererKind* = enum
    NoOp
    AGC
    Direct3D11
    Direct3D12
    GNM
    Metal
    NVN
    OpenGLES
    OpenGL
    Vulkan
    Auto

type Access* = enum
    Read
    Write
    ReadWrite

type ResetFlag* = distinct uint32
const
    ResetNone*                  = ResetFlag 0x0000_0000
    ResetFullscreen*            = ResetFlag 0x0000_0001
    ResetMSAAShift*             = ResetFlag 0x0000_0004
    ResetMSAAX2*                = ResetFlag 0x0000_0010
    ResetMSAAX4*                = ResetFlag 0x0000_0020
    ResetMSAAX8*                = ResetFlag 0x0000_0030
    ResetMSAAX16*               = ResetFlag 0x0000_0040
    ResetMSAAMask*              = ResetFlag 0x0000_0070
    ResetVSync*                 = ResetFlag 0x0000_0080
    ResetMaxAnisotropy*         = ResetFlag 0x0000_0100
    ResetCapture*               = ResetFlag 0x0000_0200
    ResetFlushAfterRender*      = ResetFlag 0x0000_2000
    ResetFlipAfterRender*       = ResetFlag 0x0000_4000
    ResetSRGBBackbuffer*        = ResetFlag 0x0000_8000
    ResetHDR10*                 = ResetFlag 0x0001_0000
    ResetHiDPI*                 = ResetFlag 0x0002_0000
    ResetDepthClamp*            = ResetFlag 0x0004_0000
    ResetSuspend*               = ResetFlag 0x0008_0000
    ResetTransparentBackbuffer* = ResetFlag 0x0010_0000
func `or`*(a, b: ResetFlag): ResetFlag {.borrow.}

type TextureFormat* = enum
    BC1, BC2, BC3, BC4, BC5, BC6H, BC7,
    ETC1, ETC2, ETC2A, ETC2A1, PTC12,
    PTC14, PTC12A, PTC14A, PTC22, PTC24, ATC,
    ATCE, ATCI,
    ASTC4X4, ASTC5X4, ASTC5X5, ASTC6X5, ASTC6X6, ASTC8X5, ASTC8X6, ASTC8X8, ASTC10X5,
    ASTC10X6, ASTC10X8, ASTC10X10, ASTC12X10, ASTC12X12,
    Unknown,
    R1, A8, R8, R8I, R8U, R8S, R16, R16I, R16U, R16F, R16S, R32I, R32U, R32F, RG8,
    RG8I, RG8U, RG8S, RG16, RG16I, RG16U, RG16F, RG16S, RG32I, RG32U, RG32F, RGB8,
    RGB8I, RGB8U, RGB8S, RGB9E5F, BGRA8, RGBA8, RGBA8I, RGBA8U, RGBA8S, RGBA16, RGBA16I,
    RGBA16U, RGBA16F, RGBA16S, RGBA32I, RGBA32U, RGBA32F, B5G6R5, R5G6B5, BGRA4, RGBA4, BGR5A1, RGB5A1, RGB10A2, RG11B10F,
    UnknownDepth,
    D16, D24, D24S8, D32, D16F, D24F, D32F, D0S8,

type UniformKind* = enum
    Sampler
    _
    Vec4
    Mat3
    Mat4

type Topology* = enum
    TriList
    TriStrip
    LineList
    LineStrip
    PointList

type TopologyConvert* = enum
    TriListFlipWinding
    TriStripFlipWinding
    TriListToLineList
    TriStripToTriList
    LienStripToLineList

type TopologySort* = enum
    DirFrontToBackMin
    DirFrontToBackAvg
    DirFrontToBackMax
    DirBackToFrontMin
    DirBackToFrontAvg
    DirBackToFrontMax
    DistFrontToBackMin
    DistFrontToBackAvg
    DistFrontToBackMax
    DistBackToFrontMin
    DistBackToFrontAvg
    DistBackToFrontMax

type ViewMode* = enum
    Default
    Sequential
    DepthAscending
    DepthDescending

type GPULimits* = object
    maxDrawCalls           : uint32
    maxBlits               : uint32
    maxTextureSize         : uint32
    maxTextureLayers       : uint32
    maxViews               : uint32
    maxFrameBuffers        : uint32
    maxFBAttachments       : uint32
    maxPrograms            : uint32
    maxShaders             : uint32
    maxTextures            : uint32
    maxTextureSamplers     : uint32
    maxComputeBindings     : uint32
    maxVertexLayouts       : uint32
    maxVertexStreams       : uint32
    maxIndexBuffers        : uint32
    maxVertexBuffers       : uint32
    maxDynamicIndexBuffers : uint32
    maxDynamicVertexBuffers: uint32
    maxUniforms            : uint32
    maxOcclusionQueries    : uint32
    maxEncoders            : uint32
    minResourceCbSize      : uint32
    transientVbSize        : uint32
    transientIbSize        : uint32

type GPUInfo* = object
    vendor_id: uint16
    device_id: uint16

type RendererCapabilities* = object
    supported         : uint64
    vendor_id         : VendorID
    device_id         : uint16
    homogeneous_depth : bool
    origin_bottom_left: bool
    gpuc              : byte
    gpus              : array[4, GPUInfo]
    limits            : GPULimits
    formats           : array[high(TextureFormat).int + 1, TextureFormat]

type
    AllocatorVTable = object
        realloc: (ptr AllocatorInterface, pointer, csize_t, csize_t, cstring, uint32) -> pointer
    AllocatorInterface* = ptr AllocatorVTable

type
    CallbackVTable = object
        fatal                 : (ptr CallbackInterface -> cstring -> uint16 -> Fatal -> cstring) -> void
        trace_vargs           : (ptr CallbackInterface {.varargs.} -> cstring -> uint16 -> cstring) -> void
        profiler_begin        : (ptr CallbackInterface -> cstring -> uint32 -> cstring -> uint16) -> void
        profiler_begin_literal: (ptr CallbackInterface -> cstring -> uint32 -> cstring -> uint16) -> void
        profiler_end          : (ptr CallbackInterface) -> void
        cache_read_size       : (ptr CallbackInterface -> uint64) -> uint32
        cache_read            : (ptr CallbackInterface -> uint64 -> pointer -> uint32) -> bool
        cache_write           : (ptr CallbackInterface -> uint64 -> pointer -> uint32) -> void
        screen_shot           : (ptr CallbackInterface -> cstring -> uint32 -> uint32 -> uint32 -> pointer -> uint32 -> bool) -> void
        capture_begin         : (ptr CallbackInterface -> uint32 -> uint32 -> uint32 -> TextureFormat -> bool) -> void
        capture_end           : (ptr CallbackInterface) -> void
        capture_frame         : (ptr CallbackInterface -> pointer -> uint32) -> void
    CallbackInterface* = ptr CallbackVTable

type Resolution* = object
    format           : TextureFormat
    width            : uint32
    height           : uint32
    reset            : ResetFlag
    num_back_buffers : byte
    max_frame_latency: byte
    debug_text_scale : byte

type NativeWindowHandle* {.size: sizeof(cint)} = enum
    Default
    Wayland

type PlatformData* = object
    ndt           : pointer
    nwh           : pointer
    context       : pointer
    back_buffer   : pointer
    back_buffer_ds: pointer
    kind          : NativeWindowHandle

type InitLimits* = object
    max_encoders        : uint16
    min_resource_cb_size: uint32
    transient_vb_size   : uint32
    transient_ib_size   : uint32

type InitObj = object
    kind         : RendererKind
    vendor_id    : VendorID
    device_id    : uint16
    capabilities : uint64
    debug        : bool
    profile      : bool
    platform_data: PlatformData
    resolution   : Resolution
    limits       : InitLimits
    callback     : ptr CallbackInterface
    allocator    : ptr AllocatorInterface

proc get_renderer_type*(): RendererKind {.importc: "bgfx_get_renderer_type", dynlib: BGFXPath.}

proc init*(ci: ptr InitObj): bool {.importc: "bgfx_init", dynlib: BGFXPath.}
proc init_ctor*(ci: ptr InitObj) {.importc: "bgfx_init_ctor", dynlib: BGFXPath.}
proc reset*(w, h: uint32, flags: ResetFlag, format: TextureFormat) {.importc: "bgfx_reset", dynlib: BGFXPath.}
proc init*(window: Window, w, h: int,
           renderer  = RendererKind.Auto,
           vendor_id = VendorID.None,
           reset     = ResetVSync) =
    var ci: InitObj
    init_ctor ci.addr
    ci.platform_data.nwh  = cast[pointer](get_x11_window_number window)
    ci.platform_data.ndt  = cast[pointer](get_x11_display_pointer window)
    ci.platform_data.kind = Default
    if not init(addr ci):
        echo red "Error: failed to initialize BGFX: "

    reset(uint32 w, uint32 h, ResetVSync, RGBA8)

    echo fmt"Initialized BGFX ({ci.resolution.width}x{ci.resolution.height}):"
    echo fmt"\tRenderer  -> {get_renderer_type()}"
    echo fmt"\tVendor ID -> {ci.vendor_id}"
    echo fmt"\tDevice ID -> {ci.device_id}"

proc shutdown*() {.importc: "bgfx_shutdown", dynlib: BGFXPath.}
