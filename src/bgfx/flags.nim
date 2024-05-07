type ClearFlag* = distinct uint16
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
proc `or`*(a, b: ClearFlag): ClearFlag {.borrow.}
