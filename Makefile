BIN = game

SRC_DIR  = ./src
LIB_DIR  = ./lib
TOOL_DIR = ./tools

all:
	nim compile --run --out:$(BIN) $(SRC_DIR)/main.nim

.PHONY: lib
lib:
	@cmake -S $(LIB_DIR)/sdl -B $(LIB_DIR)/sdl/build -DCMAKE_BUILD_TYPE=Release \
	       -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_DISABLE_INSTALL=ON
	@cmake --build $(LIB_DIR)/sdl/build -j12
	@cp $(LIB_DIR)/sdl/build/libSDL3.so* $(LIB_DIR)/

	@make -j12 -C $(LIB_DIR)/bgfx/ linux-release64
	@cp $(LIB_DIR)/bgfx/.build/linux64_gcc/bin/libbgfx-shared-libRelease.so $(LIB_DIR)/libbgfx.so

.PHONY: tools
tools:

.PHONY: restore
restore:
	@git submodule update --init --remote --merge --recursive -j 12
	@make tools
	@make lib

.PHONY: cloc
cloc:
	@cloc --vcs=git
