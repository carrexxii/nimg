import std/[strformat, strutils, sequtils]

const
    Bin = "game"

    BuildDir  = "./build"
    LibDir    = "./lib"
    ToolDir   = "./tools"
    ShaderDir = "./shaders"
    ModelDir  = "./gfx/models"

    LibFlags    = "-p:../nsdl -d:SDLDir=../nsdl"
    ShaderFlags = "--platform linux --profile spirv"
    AssimpFlags = "-DASSIMP_INSTALL=OFF -DASSIMP_NO_EXPORT=ON -DASSIMP_BUILD_TESTS=OFF -DASSIMP_INSTALL_PDB=OFF"

    ModelCompiler = fmt"{ToolDir}/naic"

proc basename(path: string; with_ext = false): string =
    let start = (path.rfind '/') + 1
    let stop  = path.rfind '.'
    if with_ext:
        result = path[start..^1]
    else:
        result = path[start..<stop]

task shaders, "Compile shaders":
    let shaders = list_files ShaderDir
    for vs_path in shaders.filter (proc (path: string): bool = path.endswith ".vs.sc"):
        let fname = vs_path.rsplit('/', maxsplit = 1)[1]
        exec fmt"{ToolDir}/bgfx/shaderc --type vertex {ShaderFlags} -f {vs_path} -o {ShaderDir}/bin/{fname[0..^4]}.bin"
    for fs_path in shaders.filter (proc (path: string): bool = path.endswith ".fs.sc"):
        let fname = fs_path.rsplit('/', maxsplit = 1)[1]
        exec fmt"{ToolDir}/bgfx/shaderc --type fragment {ShaderFlags} -f {fs_path} -o {ShaderDir}/bin/{fname[0..^4]}.bin"

task models, "Build models":
    let models = list_files ModelDir
    for model_path in models:
        exec fmt"{ModelCompiler} -f -i:{model_path} -o:{model_path.basename}.nai"

task run, "Build and run":
    shaders_task()
    models_task()
    exec fmt"nim c -r {LibFlags} --nimCache:{BuildDir} -o:{Bin} ./src/main.nim"

task build_libs, "Build dependencies":
    # BGFX
    with_dir fmt"{LibDir}/bgfx":
        exec fmt"make -j linux"
        exec fmt"make -j tools"
    exec fmt"cp {LibDir}/bgfx/.build/linux64_gcc/bin/libbgfx-shared-libDebug.so {LibDir}/libbgfx.so"
    exec fmt"cp {LibDir}/bgfx/src/bgfx_shader.sh {ShaderDir}/"
    mk_dir fmt"{ToolDir}/bgfx"
    exec fmt"cp -r {LibDir}/bgfx/tools/bin/linux/* {ToolDir}/bgfx"

    # CGLM
    exec fmt"cp -r {LibDir}/cglm/include/cglm {LibDir}/include/cglm"

task build_tools, "Build tools":
    mk_dir fmt"{ToolDir}/include"

    # Assimp
    mk_dir fmt"{ToolDir}/include/assimp"
    with_dir fmt"{ToolDir}/assimp":
        exec fmt"cmake -B . -S . {AssimpFlags}"
        exec fmt"cmake --build . -j"
    exec fmt"cp {ToolDir}/assimp/build/bin/*.so* {ToolDir}/"
    exec fmt"cp {ToolDir}/assimp/include/assimp/*.h {ToolDir}/include/assimp/"

    # Nai
    exec fmt"make -C {ToolDir}/nai"
    exec fmt"cp {ToolDir}/nai/naic {ToolDir}/"

task restore, "Fetch and build tools and library dependencies":
    exec "git submodule update --init --remote --merge --recursive -j 8"
    build_tools_task()
    build_libs_task()

task clean, "Cleanup build files":
    exec fmt"rm -f {ShaderDir}/bin/*"

task remove, "Remove build files, libraries and tools":
    clean_task()
    exec fmt"rm -rf {LibDir}/*"
    exec fmt"rm -rf {ToolDir}/*"

task stats, "Project statistics":
    exec "cloc --vcs=git"
