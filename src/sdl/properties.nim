import sdl

const
    # PropShapePointer                         = cstring "SDL.window.shape"
    # PropAndroidWindowPointer                 = cstring "SDL.window.android.window"
    # PropAndroidSurfacePointer                = cstring "SDL.window.android.surface"
    # PropUIKitWindowPointer                   = cstring "SDL.window.uikit.window"
    # PropUIKitMetalViewTagNumber              = cstring "SDL.window.uikit.metal_view_tag"
    # PropKMSDeviceIndexNumber                 = cstring "SDL.window.kmsdrm.dev_index"
    # PropKMSDRMFDNumber                       = cstring "SDL.window.kmsdrm.drm_fd"
    # PropKMSGBMDevicePointer                  = cstring "SDL.window.kmsdrm.gbm_dev"
    # PropCocoaWindowPointer                   = cstring "SDL.window.cocoa.window"
    # PropCocoaMetalViewTagNumber              = cstring "SDL.window.cocoa.metal_view_tag"
    # PropVivanteDisplayPointer                = cstring "SDL.window.vivante.display"
    # PropVivanteWindowPointer                 = cstring "SDL.window.vivante.window"
    # PropVivanteSurfacePointer                = cstring "SDL.window.vivante.surface"
    # PropWinRTWindowPointer                   = cstring "SDL.window.winrt.window"
    # PropWin32HWNDPointer                     = cstring "SDL.window.win32.hwnd"
    # PropWin32HDCPointer                      = cstring "SDL.window.win32.hdc"
    # PropWin32InstancePointer                 = cstring "SDL.window.win32.instance"
    # PropWaylandDisplayPointer                = cstring "SDL.window.wayland.display"
    # PropWaylandSurfacePointer                = cstring "SDL.window.wayland.surface"
    # PropWaylandEGLWindowPointer              = cstring "SDL.window.wayland.egl_window"
    # PropWaylandXDGSurfacePointer             = cstring "SDL.window.wayland.xdg_surface"
    # PropWaylandXDGToplevelPointer            = cstring "SDL.window.wayland.xdg_toplevel"
    # PropWaylandXDGToplevelExportHandleString = cstring "SDL.window.wayland.xdg_toplevel_export_handle"
    # PropWaylandXDGPopupPointer               = cstring "SDL.window.wayland.xdg_popup"
    # PropWaylandXDGPositionerPointer          = cstring "SDL.window.wayland.xdg_positioner"
    PropX11DisplayPointer                    = cstring "SDL.window.x11.display"
    PropX11ScreenNumber                      = cstring "SDL.window.x11.screen"
    PropX11WindowNumber                      = cstring "SDL.window.x11.window"

type
    Property*   = pointer
    PropertyID* = distinct cint
proc get_property       (id: PropertyID, name: cstring, default: pointer): Property {.importc: "SDL_GetProperty"      , dynlib: LibPath.}
proc get_number_property(id: PropertyID, name: cstring, default: int64  ): int64    {.importc: "SDL_GetNumberProperty", dynlib: LibPath.}
proc get_window_property(window: Window): PropertyID {.importc: "SDL_GetWindowProperties", dynlib: LibPath.}

proc get_x11_display_pointer*(window: Window): Property = get_property(get_window_property(window), PropX11DisplayPointer, nil)
proc get_x11_screen_number*  (window: Window): int64    = get_number_property(get_window_property(window), PropX11ScreenNumber, 0)
proc get_x11_window_number*  (window: Window): int64    = get_number_property(get_window_property(window), PropX11WindowNumber, 0)
