type StateFlag* = distinct uint64
func `or`*(a, b: StateFlag): StateFlag {.borrow.}
const
    StateWriteR*               = StateFlag 0x0000_0000_0000_0001
    StateWriteG*               = StateFlag 0x0000_0000_0000_0002
    StateWriteB*               = StateFlag 0x0000_0000_0000_0004
    StateWriteA*               = StateFlag 0x0000_0000_0000_0008
    StateWriteZ*               = StateFlag 0x0000_0040_0000_0000
    StateWriteRGB*             = StateWriteR or StateWriteG or StateWriteB
    StateWriteMask*            = StateWriteRGB or StateWriteA or StateWriteZ
    StateDepthTestLess*        = StateFlag 0x0000_0000_0000_0010
    StateDepthTestLEqual*      = StateFlag 0x0000_0000_0000_0020
    StateDepthTestEqual*       = StateFlag 0x0000_0000_0000_0030
    StateDepthTestGEqual*      = StateFlag 0x0000_0000_0000_0040
    StateDepthTestGreater*     = StateFlag 0x0000_0000_0000_0050
    StateDepthTestNotEqual*    = StateFlag 0x0000_0000_0000_0060
    StateDepthTestNever*       = StateFlag 0x0000_0000_0000_0070
    StateDepthTestAlways*      = StateFlag 0x0000_0000_0000_0080
    StateDepthTestShift*       = StateFlag 0x0000_0000_0000_0004
    StateDepthTestMask*        = StateFlag 0x0000_0000_0000_00F0
    StateBlendZero*            = StateFlag 0x0000_0000_0000_1000
    StateBlendOne*             = StateFlag 0x0000_0000_0000_2000
    StateBlendSrcColour*       = StateFlag 0x0000_0000_0000_3000
    StateBlendInvSrcColour*    = StateFlag 0x0000_0000_0000_4000
    StateBlendSrcAlpha*        = StateFlag 0x0000_0000_0000_5000
    StateBlendInvSrcAlpha*     = StateFlag 0x0000_0000_0000_6000
    StateBlendDstAlpha*        = StateFlag 0x0000_0000_0000_7000
    StateBlendInvDstAlpha*     = StateFlag 0x0000_0000_0000_8000
    StateBlendDstCOLOR*        = StateFlag 0x0000_0000_0000_9000
    StateBlendInvDstCOLOR*     = StateFlag 0x0000_0000_0000_A000
    StateBlendSrcAlphaSat*     = StateFlag 0x0000_0000_0000_B000
    StateBlendFactor*          = StateFlag 0x0000_0000_0000_C000
    StateBlendInvFactor*       = StateFlag 0x0000_0000_0000_d000
    StateBlendShift*           = StateFlag 0x0000_0000_0000_000C
    StateBlendMask*            = StateFlag 0x0000_0000_0FFF_F000
    StateBlendEquationAdd*     = StateFlag 0x0000_0000_0000_0000
    StateBlendEquationSub*     = StateFlag 0x0000_0000_1000_0000
    StateBlendEquationRevSub*  = StateFlag 0x0000_0000_2000_0000
    StateBlendEquationMin*     = StateFlag 0x0000_0000_3000_0000
    StateBlendEquationMax*     = StateFlag 0x0000_0000_4000_0000
    StateBlendEquationShift*   = StateFlag 0x0000_0000_0000_001C
    StateBlendEquationMask*    = StateFlag 0x0000_0003_F000_0000
    StateCullCW*               = StateFlag 0x0000_0010_0000_0000
    StateCullCCW*              = StateFlag 0x0000_0020_0000_0000
    StateCullShift*            = StateFlag 0x0000_0000_0000_0024
    StateCullMask*             = StateFlag 0x0000_0030_0000_0000
    StateAlphaRefShift*        = StateFlag 0x0000_0000_0000_0028
    StateAlphaRefMask*         = StateFlag 0x0000_FF00_0000_0000
    StatePTTriStrip*           = StateFlag 0x0001_0000_0000_0000
    StatePTLines*              = StateFlag 0x0002_0000_0000_0000
    StatePTLineStrip*          = StateFlag 0x0003_0000_0000_0000
    StatePTPoints*             = StateFlag 0x0004_0000_0000_0000
    StatePTShift*              = StateFlag 0x0000_0000_0000_0030
    StatePTMask*               = StateFlag 0x0007_0000_0000_0000
    StatePointSizeShift*       = StateFlag 0x0000_0000_0000_0034
    StatePointSizeMask*        = StateFlag 0x00F0_0000_0000_0000
    StateMSAA*                 = StateFlag 0x0100_0000_0000_0000
    StateLineAA*               = StateFlag 0x0200_0000_0000_0000
    StateConservativeRaster*   = StateFlag 0x0400_0000_0000_0000
    StateNone*                 = StateFlag 0x0000_0000_0000_0000
    StateFrontCCW*             = StateFlag 0x0000_0080_0000_0000
    StateBlendIndependent*     = StateFlag 0x0000_0004_0000_0000
    StateBlendAlphaToCoverage* = StateFlag 0x0000_0008_0000_0000
    StateDefault*              = StateWriteRGB or StateWriteA or StateWriteZ or
                                 StateDepthTestLess or StateCullCW or StateMSAA
    StateMask*                 = StateFlag 0xFFFF_FFFF_FFFF_FFFFU
    StateReservedShift*        = StateFlag 0x0000_0000_0000_003D
    StateReservedMask*         = StateFlag 0xE000_0000_0000_0000U
template StateAlphaRef*(x: typed): StateFlag =
    (x.StateFlag shl StateAlphaRefShift) and StateAlphaRefMask
template StatePointSize*(x: typed): StateFlag =
    (x.StateFlag shl StatePointSizeShift) and StatePointSizeMask

type DiscardFlag* = distinct uint8
func `or`*(a, b: DiscardFlag): DiscardFlag {.borrow.}
const
    DiscardNone*          = DiscardFlag 0x00
    DiscardBindings*      = DiscardFlag 0x01
    DiscardIndexBuffer*   = DiscardFlag 0x02
    DiscardInstanceData*  = DiscardFlag 0x04
    DiscardState*         = DiscardFlag 0x08
    DiscardTransform*     = DiscardFlag 0x10
    DiscardVertexStreams* = DiscardFlag 0x20
    DiscardAll*           = DiscardFlag 0xFF

type ClearFlag* = distinct uint16
func `or`*(a, b: ClearFlag): ClearFlag {.borrow.}
const
    ClearNone*           = ClearFlag 0x0000
    ClearColour*         = ClearFlag 0x0001
    ClearDepth*          = ClearFlag 0x0002
    ClearStencil*        = ClearFlag 0x0004
    ClearDiscardColour0* = ClearFlag 0x0008
    ClearDiscardColour1* = ClearFlag 0x0010
    ClearDiscardColour2* = ClearFlag 0x0020
    ClearDiscardColour3* = ClearFlag 0x0040
    ClearDiscardColour4* = ClearFlag 0x0080
    ClearDiscardColour5* = ClearFlag 0x0100
    ClearDiscardColour6* = ClearFlag 0x0200
    ClearDiscardColour7* = ClearFlag 0x0400
    ClearDiscardDepth*   = ClearFlag 0x0800
    ClearDiscardStencil* = ClearFlag 0x1000

type BufferFlag* = distinct uint16
func `or`*(a, b: BufferFlag): BufferFlag {.borrow.}
const
    BufferComputeFormat8x1*   = BufferFlag 0x0001
    BufferComputeFormat8x2*   = BufferFlag 0x0002
    BufferComputeFormat8x4*   = BufferFlag 0x0003
    BufferComputeFormat16x1*  = BufferFlag 0x0004
    BufferComputeFormat16x2*  = BufferFlag 0x0005
    BufferComputeFormat16x4*  = BufferFlag 0x0006
    BufferComputeFormat32x1*  = BufferFlag 0x0007
    BufferComputeFormat32x2*  = BufferFlag 0x0008
    BufferComputeFormat32x4*  = BufferFlag 0x0009
    BufferComputeFormatShift* = BufferFlag 0x0000
    BufferComputeFormatMask*  = BufferFlag 0x000f
    BufferComputeTypeInt*     = BufferFlag 0x0010
    BufferComputeTypeUInt*    = BufferFlag 0x0020
    BufferComputeTypeFloat*   = BufferFlag 0x0030
    BufferComputeTypeShift*   = BufferFlag 0x0004
    BufferComputeTypeMask*    = BufferFlag 0x0030
    BufferNone*               = BufferFlag 0x0000
    BufferComputeRead*        = BufferFlag 0x0100
    BufferComputeWrite*       = BufferFlag 0x0200
    BufferDrawIndirect*       = BufferFlag 0x0400
    BufferAlloweResize*       = BufferFlag 0x0800
    BufferIndex32*            = BufferFlag 0x1000

type SamplerFlag* = distinct uint32
func `or`*(a, b: SamplerFlag): SamplerFlag {.borrow.}
const
    SamplerUMirror*           = SamplerFlag 0x0000_0001
    SamplerUClamp*            = SamplerFlag 0x0000_0002
    SamplerUBorder*           = SamplerFlag 0x0000_0003
    SamplerUShift*            = SamplerFlag 0x0000_0000
    SamplerUMask*             = SamplerFlag 0x0000_0003
    SamplerVMirror*           = SamplerFlag 0x0000_0004
    SamplerVClamp*            = SamplerFlag 0x0000_0008
    SamplerVBorder*           = SamplerFlag 0x0000_000C
    SamplerVShift*            = SamplerFlag 0x0000_0002
    SamplerVMask*             = SamplerFlag 0x0000_000C
    SamplerWMirror*           = SamplerFlag 0x0000_0010
    SamplerWClamp*            = SamplerFlag 0x0000_0020
    SamplerWBorder*           = SamplerFlag 0x0000_0030
    SamplerWShift*            = SamplerFlag 0x0000_0004
    SamplerWMask*             = SamplerFlag 0x0000_0030
    SamplerMinPoint*          = SamplerFlag 0x0000_0040
    SamplerMinAnisotropic*    = SamplerFlag 0x0000_0080
    SamplerMinShift*          = SamplerFlag 0x0000_0006
    SamplerMinMask*           = SamplerFlag 0x0000_00C0
    SamplerMagPoint*          = SamplerFlag 0x0000_0100
    SamplerMagAnisotropic*    = SamplerFlag 0x0000_0200
    SamplerMagShift*          = SamplerFlag 0x0000_0008
    SamplerMagMask*           = SamplerFlag 0x0000_0300
    SamplerMIPPoint*          = SamplerFlag 0x0000_0400
    SamplerMIPShift*          = SamplerFlag 0x0000_000A
    SamplerMIPMask*           = SamplerFlag 0x0000_0400
    SamplerCompareLess*       = SamplerFlag 0x0001_0000
    SamplerCompareLEqual*     = SamplerFlag 0x0002_0000
    SamplerCompareEqual*      = SamplerFlag 0x0003_0000
    SamplerCompareGEqual*     = SamplerFlag 0x0004_0000
    SamplerCompareGreater*    = SamplerFlag 0x0005_0000
    SamplerCompareNotEqual*   = SamplerFlag 0x0006_0000
    SamplerCompareNever*      = SamplerFlag 0x0007_0000
    SamplerCompareAlways*     = SamplerFlag 0x0008_0000
    SamplerCompareShift*      = SamplerFlag 0x0000_0010
    SamplerCompareMask*       = SamplerFlag 0x000F_0000
    SamplerBorderColourShift* = SamplerFlag 0x0000_0018
    SamplerBorderColourMask*  = SamplerFlag 0x0F00_0000
    SamplerReservedShift*     = SamplerFlag 0x0000_001C
    SamplerNone*              = SamplerFlag 0x0000_0000
    SamplerSampleStencil*     = SamplerFlag 0x0010_0000
    SamplerPoint*             = SamplerMinPoint or SamplerMagPoint or SamplerMIPPoint
    SamplerUVWMirror*         = SamplerUMirror or SamplerVMirror or SamplerWMirror
    SamplerUVWClamp*          = SamplerUClamp or SamplerVClamp or SamplerWClamp
    SamplerUVWBorder*         = SamplerUBorder or SamplerVBorder or SamplerWBorder
    SamplerBitsMask*          = SamplerUMask or SamplerVMask or SamplerWMask or
                                SamplerMinMask or SamplerMagMask or SamplerMIPMask or
                                SamplerCompareMask
template sampler_border_colour*(v: typed): SamplerFlag =
    (v.SamplerFlag shl SamplerBorderColourShift) and SamplerBorderColourMask

type StencilFlag* = distinct uint32
func `or`*(a, b: StencilFlag): StencilFlag {.borrow.}
const
    StencilFuncRefShift*   = StencilFlag 0x0000_0000
    StencilFuncRefMask*    = StencilFlag 0x0000_00FF
    StencilFuncRMaskShift* = StencilFlag 0x0000_0008
    StencilFuncRMaskMask*  = StencilFlag 0x0000_FF00
    StencilNone*           = StencilFlag 0x0000_0000
    StencilMask*           = StencilFlag 0xFFFF_FFFF
    StencilDefault*        = StencilFlag 0x0000_0000
    StencilTestLess*       = StencilFlag 0x0001_0000
    StencilTestLEqual*     = StencilFlag 0x0002_0000
    StencilTestEqual*      = StencilFlag 0x0003_0000
    StencilTestGEqual*     = StencilFlag 0x0004_0000
    StencilTestGreater*    = StencilFlag 0x0005_0000
    StencilTestNotEqual*   = StencilFlag 0x0006_0000
    StencilTestNever*      = StencilFlag 0x0007_0000
    StencilTestAlways*     = StencilFlag 0x0008_0000
    StencilTestShift*      = StencilFlag 0x0000_0010
    StencilTestMask*       = StencilFlag 0x000F_0000
    StencilOpFailSZero*    = StencilFlag 0x0000_0000
    StencilOpFailSKeep*    = StencilFlag 0x0010_0000
    StencilOpFailSReplace* = StencilFlag 0x0020_0000
    StencilOpFailSIncr*    = StencilFlag 0x0030_0000
    StencilOpFailSIncrSAT* = StencilFlag 0x0040_0000
    StencilOpFailSDecr*    = StencilFlag 0x0050_0000
    StencilOpFailSDecrSAT* = StencilFlag 0x0060_0000
    StencilOpFailSInvert*  = StencilFlag 0x0070_0000
    StencilOpFailSShift*   = StencilFlag 0x0000_0014
    StencilOpFailSMask*    = StencilFlag 0x00F0_0000
    StencilOpFailZZero*    = StencilFlag 0x0000_0000
    StencilOpFailZKeep*    = StencilFlag 0x0100_0000
    StencilOpFailZReplace* = StencilFlag 0x0200_0000
    StencilOpFailZIncr*    = StencilFlag 0x0300_0000
    StencilOpFailZIncrSAT* = StencilFlag 0x0400_0000
    StencilOpFailZDecr*    = StencilFlag 0x0500_0000
    StencilOpFailZDecrSAT* = StencilFlag 0x0600_0000
    StencilOpFailZInvert*  = StencilFlag 0x0700_0000
    StencilOpFailZShift*   = StencilFlag 0x0000_0018
    StencilOpFailZMask*    = StencilFlag 0x0f00_0000
    StencilOpPassZZero*    = StencilFlag 0x0000_0000
    StencilOpPassZKeep*    = StencilFlag 0x1000_0000
    StencilOpPassZReplace* = StencilFlag 0x2000_0000
    StencilOpPassZIncr*    = StencilFlag 0x3000_0000
    StencilOpPassZIncrSAT* = StencilFlag 0x4000_0000
    StencilOpPassZDecr*    = StencilFlag 0x5000_0000
    StencilOpPassZDecrSAT* = StencilFlag 0x6000_0000
    StencilOpPassZInvert*  = StencilFlag 0x7000_0000
    StencilOpPassZShift*   = StencilFlag 0x0000_001C
    StencilOpPassZMask*    = StencilFlag 0xF000_0000
template stencil_func_ref*(x: typed) =
    (x.uint32 shl StencilFuncRefShift) and StencilFuncRefMask
template stencil_func_rmask*(x: typed) =
    (x.uint32 shl StencilFuncRMaskShift) and StencilFuncRMaskMask
