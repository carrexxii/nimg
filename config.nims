import std/[strformat, strutils, sequtils]

const
    Bin = "game"

    BuildDir  = "./build"
    LibDir    = "./lib"
    ToolDir   = "./tools"
    ShaderDir = "./shaders"
    ModelDir  = "./gfx/models"

    LibFlags    = "-p:../nsdl -d:SDLDir=../nsdl -p:../nbgfx -p:../ngm"
    ShaderFlags = "--platform linux --profile spirv"

    ModelCompiler = fmt"{ToolDir}/naic"

func basename(path: string; with_ext = false): string =
    let start = (path.rfind '/') + 1
    let stop  = path.rfind '.'
    if with_ext:
        result = path[start..^1]
    else:
        result = path[start..<stop]

task build_shaders, "Compile shaders":
    let shaders = list_files ShaderDir
    for vs_path in shaders.filter (proc (path: string): bool = path.endswith ".vs.sc"):
        let fname = vs_path.rsplit('/', maxsplit = 1)[1]
        exec fmt"{ToolDir}/bgfx/shaderc --type vertex {ShaderFlags} -f {vs_path} -o {ShaderDir}/bin/{fname[0..^4]}.bin"
    for fs_path in shaders.filter (proc (path: string): bool = path.endswith ".fs.sc"):
        let fname = fs_path.rsplit('/', maxsplit = 1)[1]
        exec fmt"{ToolDir}/bgfx/shaderc --type fragment {ShaderFlags} -f {fs_path} -o {ShaderDir}/bin/{fname[0..^4]}.bin"

task build_models, "Build models":
    let models = list_files ModelDir
    for model_path in models:
        exec fmt"{ModelCompiler} -f -i:{model_path} -o:{model_path.basename}.nai"

task run, "Build and run":
    #build_shaders_task()
    #build_models_task()
    exec fmt"nim c -r {LibFlags} --nimCache:{BuildDir} -o:{Bin} ./src/main.nim"
    rm_dir "./temp"

task build_libs, "Build dependencies":
    discard

task build_tools, "Build tools":
    discard

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
