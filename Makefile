BIN = game

SRC_DIR    = ./src
BUILD_DIR  = ./build
SHADER_DIR = ./shaders
GFX_DIR    = ./gfx
MODEL_DIR  = $(GFX_DIR)/models
LIB_DIR    = ./lib
TOOL_DIR   = ./tools

SHADERC = $(TOOL_DIR)/bgfx/shaderc
MODELC  = $(TOOL_DIR)/naic

VS_SRC := $(wildcard $(SHADER_DIR)/*.vs.sc)
FS_SRC := $(wildcard $(SHADER_DIR)/*.fs.sc)
VS_BIN := $(VS_SRC:$(SHADER_DIR)/%=$(SHADER_DIR)/bin/%)
FS_BIN := $(FS_SRC:$(SHADER_DIR)/%=$(SHADER_DIR)/bin/%)
SHADER_FLAGS := --platform linux --profile spirv

MDL_SRC := $(wildcard $(MODEL_DIR)/*)
MDL_BIN := $(MDL_SRC:$(MODEL_DIR)/%=$(GFX_DIR)/%)

all:
	@mkdir -p $(SHADER_DIR)/bin
	@make -j12 shaders
	@-nim compile --run --out:$(BIN) $(SRC_DIR)/main.nim
	@rm -rf ./temp

.PHONY: shaders
shaders: $(VS_BIN) $(FS_BIN)
$(VS_BIN): $(SHADER_DIR)/bin/%: $(SHADER_DIR)/%
	@$(SHADERC) --type vertex $(SHADER_FLAGS) -f $< -o $(basename $@).bin
$(FS_BIN): $(SHADER_DIR)/bin/%: $(SHADER_DIR)/%
	@$(SHADERC) --type fragment $(SHADER_FLAGS) -f $< -o $(basename $@).bin

.PHONY: models
models: $(MDL_BIN)
$(MDL_BIN): $(MDL_SRC)
	@$(MODELC) -i:$< -o:$(basename $@).bin

.PHONY: lib
lib:
	@cmake -S $(LIB_DIR)/sdl -B $(LIB_DIR)/sdl/build -DCMAKE_BUILD_TYPE=Release \
	       -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON
	@cmake --build $(LIB_DIR)/sdl/build -j12
	@cp $(LIB_DIR)/sdl/build/libSDL3.so* $(LIB_DIR)/

	@mkdir -p $(TOOL_DIR)/bgfx
	@make -j12 -C $(LIB_DIR)/bgfx/ linux
	@make -j12 -C $(LIB_DIR)/bgfx/ tools
	@cp $(LIB_DIR)/bgfx/.build/linux64_gcc/bin/libbgfx-shared-libDebug.so $(LIB_DIR)/libbgfx.so
	@cp -r $(LIB_DIR)/bgfx/tools/bin/linux/* $(TOOL_DIR)/bgfx
	@cp $(LIB_DIR)/bgfx/src/bgfx_shader.sh $(SHADER_DIR)/

	@cp -r $(LIB_DIR)/cglm/include/cglm $(LIB_DIR)/include/cglm

	@echo "Finished building libraries"

.PHONY: tools
tools:
	@mkdir -p $(TOOL_DIR)/include

	@mkdir -p $(TOOL_DIR)/include/assimp
	@cmake -S $(TOOL_DIR)/assimp -B $(TOOL_DIR)/assimp -DASSIMP_INSTALL=OFF -DASSIMP_DOUBLE_PRECISION=ON\
	       -DASSIMP_NO_EXPORT=ON -DASSIMP_BUILD_TESTS=OFF -DASSIMP_INSTALL_PDB=OFF
	@cmake --build $(TOOL_DIR)/assimp -j12
	@cp $(TOOL_DIR)/assimp/build/bin/*.so* $(TOOL_DIR)/
	@cp $(TOOL_DIR)/assimp/include/assimp/*.h $(TOOL_DIR)/include/assimp/

	@make -C $(TOOL_DIR)/nai
	@cp $(TOOL_DIR)/nai/naic $(TOOL_DIR)/

	@echo "Finished building tools"

.PHONY: restore
restore:
	@git submodule update --init --remote --merge --recursive -j 12
	@make tools
	@make lib
	@echo "Restore complete"

.PHONY: clean
clean:
	@rm -f $(SHADER_DIR)/bin/*
	@echo "Shader binaries removed"

.PHONY: remove
remove: clean
	@rm -rf $(LIB_DIR)/*
	@echo "Libraries removed"
	@rm -rf $(TOOL_DIR)/*
	@echo "Tools removed"

.PHONY: cloc
cloc:
	@cloc --vcs=git
