import common
from ../cglm/cglm import Mat4x4, UColour, UBlack
import buffer, shader

type Encoder* = distinct pointer

{.push dynlib: BGFXPath.}
using
    e       : Encoder
    stream  : VertexStream
    layout  : VBOLayout
    view_id : ViewID
    sampler : Uniform
    texture : Texture
    stage   : ShaderStage
    program : Program
    discards: DiscardFlag

# set_transform - matrices might be generic (c version is a void*)
proc start*(for_thread: bool): Encoder {.importc: "bgfx_encoder_begin".}
proc stop*(e)                          {.importc: "bgfx_encoder_end"  .}
proc touch*(e, view_id)                {.importc: "bgfx_encoder_touch".}

proc set_marker*(e; name: cstring; len: int32)                           {.importc: "bgfx_encoder_set_marker"                                  .}
proc set_condition*(e; handle: OcclusionQuery; visible: bool)            {.importc: "bgfx_encoder_set_condition"                               .}
proc set_stencil*(e; front, back: StencilFlag)                           {.importc: "bgfx_encoder_set_stencil"                                 .}
proc set_scissor*(e; x, y, w, h: uint16): ScissorCache                   {.importc: "bgfx_encoder_set_scissor"                                 .}
proc set_scissor*(e; cache: ScissorCache): ScissorCache                  {.importc: "bgfx_encoder_set_scissor_cached"                          .}
proc set_transform*(e; matrices: ptr Mat4x4; count: uint16): MatrixCache {.importc: "bgfx_encoder_set_transform"                               .}
proc set_transform*(e; cache: MatrixCache; count: uint16)                {.importc: "bgfx_encoder_set_transform_cached"                        .}
proc set_uniform*(e; uniform: Uniform; count: uint16)                    {.importc: "bgfx_encoder_set_uniform"                                 .}
proc set_ibo*(e; ibo: IBO; start, count: uint32)                         {.importc: "bgfx_encoder_set_index_buffer"                            .}
proc set_ibo*(e; ibo: DIBO; start, count: uint32)                        {.importc: "bgfx_encoder_set_dynamic_index_buffer"                    .}
proc set_ibo*(e; ibo: ptr TIBO; start, count: uint32)                    {.importc: "bgfx_encoder_set_transient_index_buffer"                  .}
proc set_vbo*(e; stream; vbo: VBO; start, count: uint32)                 {.importc: "bgfx_encoder_set_vertex_buffer"                           .}
proc set_vbo*(e; stream; vbo: VBO; start, count: uint32; layout)         {.importc: "bgfx_encoder_set_vertex_buffer_with_layout"               .}
proc set_vbo*(e; stream; vbo: DVBO; start, count: uint32)                {.importc: "bgfx_encoder_set_dynamic_vertex_buffer"                   .}
proc set_vbo*(e; stream; vbo: DVBO; start, count: uint32; layout)        {.importc: "bgfx_encoder_set_dynamic_vertex_buffer_with_layout"       .}
proc set_vbo*(e; stream; vbo: ptr TVBO; start, count: uint32)            {.importc: "bgfx_encoder_set_transient_vertex_buffer"                 .}
proc set_vbo*(e; stream; vbo: ptr TVBO; start, count: uint32; layout)    {.importc: "bgfx_encoder_set_transient_vertex_buffer_with_layout"     .}
proc set_vertex_count*(e; count: uint32)                                 {.importc: "bgfx_encoder_set_vertex_count"                            .}
proc set_instance*(e; instance: ptr Instance; start, count: uint32)      {.importc: "bgfx_encoder_set_instance_data_buffer"                    .}
proc set_instance*(e; vbo: VBO; start, count: uint32)                    {.importc: "bgfx_encoder_set_instance_data_from_vertex_buffer"        .}
proc set_instance*(e; vbo: DVBO; start, count: uint32)                   {.importc: "bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer".}
proc set_instance_count*(e; count: uint32)                               {.importc: "bgfx_encoder_set_instance_count"                          .}
proc set_texture*(e; stage; sampler; texture; flags: SamplerFlag)        {.importc: "bgfx_encoder_set_texture"                                 .}

proc alloc_transform*(e; transform: ptr Transform; count: uint16): MatrixCache {.importc: "bgfx_encoder_alloc_transform".}
proc discard_encoder*(e; discards)                                             {.importc: "bgfx_encoder_discard"        .}
proc blit*(e; view_id; dst: Texture; dst_mip: MIPLevel; dst_x, dst_y, dst_z: uint16;
                       src: Texture; src_mip: MIPLevel; src_x, src_y, src_z: uint16;
           width, height, depth: uint16) {.importc: "bgfx_encoder_blit".}

proc submit_frame*(capture: bool): uint32 {.importc: "bgfx_frame".}

# TODO:
    # BGFX_C_API void bgfx_encoder_set_compute_index_buffer(bgfx_encoder_t* _this, uint8_t _stage, bgfx_index_buffer_handle_t _handle, bgfx_access_t _access);
    # BGFX_C_API void bgfx_encoder_set_compute_vertex_buffer(bgfx_encoder_t* _this, uint8_t _stage, bgfx_vertex_buffer_handle_t _handle, bgfx_access_t _access);
    # BGFX_C_API void bgfx_encoder_set_compute_dynamic_index_buffer(bgfx_encoder_t* _this, uint8_t _stage, bgfx_dynamic_index_buffer_handle_t _handle, bgfx_access_t _access);
    # BGFX_C_API void bgfx_encoder_set_compute_dynamic_vertex_buffer(bgfx_encoder_t* _this, uint8_t _stage, bgfx_dynamic_vertex_buffer_handle_t _handle, bgfx_access_t _access);
    # BGFX_C_API void bgfx_encoder_set_compute_indirect_buffer(bgfx_encoder_t* _this, uint8_t _stage, bgfx_indirect_buffer_handle_t _handle, bgfx_access_t _access);
    # BGFX_C_API void bgfx_encoder_set_image(bgfx_encoder_t* _this, uint8_t _stage, bgfx_texture_handle_t _handle, uint8_t _mip, bgfx_access_t _access, bgfx_texture_format_t _format);

    # BGFX_C_API void bgfx_encoder_dispatch(bgfx_encoder_t* _this, bgfx_view_id_t _id, bgfx_program_handle_t _program, uint32_t _numX, uint32_t _numY, uint32_t _numZ, uint8_t _flags);
    # BGFX_C_API void bgfx_encoder_dispatch_indirect(bgfx_encoder_t* _this, bgfx_view_id_t _id, bgfx_program_handle_t _program, bgfx_indirect_buffer_handle_t _indirectHandle, uint32_t _start, uint32_t _num, uint8_t _flags);

proc set_state*(e; state: StateFlag; colour = UBlack) {.importc: "bgfx_encoder_set_state".}
proc set_state*(state: StateFlag; colour = UBlack)    {.importc: "bgfx_set_state"        .}

proc submit*(view_id; program; depth: uint32 = 0; discards = DiscardNone)                                 {.importc: "bgfx_submit"                        .}
proc submit*(e; view_id; program; depth: uint32; discards)                                                {.importc: "bgfx_encoder_submit"                .}
proc submit*(e; view_id; program; query: OcclusionQuery; depth: uint32; discards)                         {.importc: "bgfx_encoder_submit_occlusion_query".}
proc submit_indirect*(e; view_id; program; handle: IndirectHandle; start, count, depth: uint32; discards) {.importc: "bgfx_encoder_indirect"              .}
proc submit_indirect*(e; view_id; program; handle: IndirectHandle; start: uint32; ibo: IBO; discards)     {.importc: "bgfx_encoder_indirect_count"        .}

# BGFX_C_API void bgfx_submit(bgfx_view_id_t _id, bgfx_program_handle_t _program, uint32_t _depth, uint8_t _flags);

{.pop.}