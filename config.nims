# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import std/[os, strformat, strutils, sequtils, enumerate]

const ShaderFlags = "--platform linux --profile spirv"

let
    cwd = get_current_dir()
    bin_path   = "game"
    src_dir    = "./src"
    lib_dir    = "./lib"
    shader_dir = "./shaders"
    tool_dir   = "./tools"
    build_dir  = "./build"
    test_dir   = "./tests"
    gfx_dir    = "./gfx"
    entry      = src_dir / "main.nim"
    deps: seq[tuple[src, dst, tag: string; cmds: seq[string]]] = @[
        (src  : "https://github.com/carrexxii/nai",
         dst  : tool_dir / "nai",
         tag  : "",
         cmds : @[&"nim restore --skipParentCfg",
                  &"nim build --skipParentCfg"]),
        (src  : "https://github.com/carrexxii/nsdl",
         dst  : lib_dir / "nsdl",
         tag  : "",
         cmds : @[&"nim restore --skipParentCfg"]),
        (src  : "https://github.com/carrexxii/ngfx",
         dst  : lib_dir / "ngfx",
         tag  : "",
         cmds : @[&"nim restore --skipParentCfg",
                  &"mv tools/shaderc {cwd / tool_dir}/",
                  &"mv lib/bgfx_shader.sh {cwd / shader_dir}/"]),
        (src  : "https://github.com/carrexxii/ngm",
         dst  : lib_dir / "ngm",
         tag  : "",
         cmds : @[&"nim restore --skipParentCfg"]),
    ]

    include_dirs = ["nsdl/", "ngfx/", "ngm/"]
    linker_flags = &"-L{lib_dir} -Wl,-rpath,'\\$ORIGIN/{lib_dir}' "
    flags = (include_dirs.map_it(&"-p:./{lib_dir / it}").join " ") &
            &" --nimCache:{build_dir} -o:{bin_path} --passL:\"{linker_flags}\" " &
            &" -l:\"{linker_flags}\""
    debug_flags   = &"--cc:tcc {flags} --passL:\"-ldl -lm\" --tlsEmulation:on -d:useMalloc"
    release_flags = &"--cc:gcc {flags} -d:release -d:danger --opt:speed"
    post_release = @[""]

#[ -------------------------------------------------------------------- ]#

proc red    (s: string): string = &"\e[31m{s}\e[0m"
proc green  (s: string): string = &"\e[32m{s}\e[0m"
proc yellow (s: string): string = &"\e[33m{s}\e[0m"
proc blue   (s: string): string = &"\e[34m{s}\e[0m"
proc magenta(s: string): string = &"\e[35m{s}\e[0m"
proc cyan   (s: string): string = &"\e[36m{s}\e[0m"

proc error(s: string)   = echo red    &"Error: {s}"
proc warning(s: string) = echo yellow &"Warning: {s}"

var cmd_count = 0
proc run(cmd: string) =
    if defined `dry-run`:
        echo blue &"[{cmd_count}] ", cmd
        cmd_count += 1
    else:
        exec cmd

func is_git_repo(url: string): bool =
    (gorge_ex &"git ls-remote -q {url}")[1] == 0

#[ -------------------------------------------------------------------- ]#

task restore, "Fetch and build dependencies":
    run &"rm -rf {lib_dir}/*"
    run &"rm -rf {tool_dir}/*"
    run &"git submodule update --init --remote --merge -j 8"
    for dep in deps:
        if is_git_repo dep.src:
            with_dir dep.dst:
                run &"git checkout {dep.tag}"
        else:
            run &"curl -o {lib_dir / (dep.src.split '/')[^1]} {dep.src}"

        with_dir dep.dst:
            for cmd in dep.cmds:
                run cmd

task build_models, "Build models":
    let models = list_files (gfx_dir / "models")
    for model_path in models:
        let output_path = model_path.replace(".glb", ".nai")
        # run &"{tool_dir}/nai/nai -c {tool_dir}/nai.ini -i:{model_dir} -o:{output_path}"

task build_shaders, "Compile shaders":
    mk_dir (shader_dir / "bin")
    let shaders = list_files shader_dir
    for vs_path in shaders.filter_it (it.endswith ".vs.sc"):
        let fname = vs_path.rsplit('/', maxsplit = 1)[1].replace("vs.sc", "bin")
        run &"{tool_dir}/shaderc --type vertex {ShaderFlags} -f {vs_path} -o {shader_dir}/bin/{fname}"
    for fs_path in shaders.filter_it (it.endswith ".fs.sc"):
        let fname = fs_path.rsplit('/', maxsplit = 1)[1].replace("fs.sc", "bin")
        run &"{tool_dir}/shaderc --type fragment {ShaderFlags} -f {fs_path} -o {shader_dir}/bin/{fname}"

task build, "Build the project (debug build)":
    run &"nim c {debug_flags} {entry}"

task build_all, "Build the project (debug build) including assets":
    build_models_task()
    build_shaders_task()
    build_task()

task release, "Build the project (release build)":
    run &"nim c {release_flags} {entry}"
    for cmd in post_release:
        run cmd

task run, "Build and run with debug build":
    echo flags
    build_task()
    run &"./{bin_path}"

task test, "Run the project's tests":
    build_task()
    echo "No tests"

task clean, "Remove all compiled/cache files":
    run &"rm -rf {build_dir}/*"
    run &"rm -rf {shader_dir}/bin/*"
    run &"rm {bin_path}"

task remove, "Remove all build files, libraries and tools":
    clean_task()
    run &"rm -rf {lib_dir}/*"
    run &"rm -rf {tool_dir}/*"

task info, "Print out information about the project":
    echo green &"NimG - '{yellow bin_path}'"
    if deps.len > 0:
        echo &"{deps.len} Dependencies:"
    for (i, dep) in enumerate deps:
        let is_git = is_git_repo dep.src
        let tag =
            if is_git and dep.tag != "":
                "@" & dep.tag
            elif is_git: "@HEAD"
            else       : ""
        echo &"    [{i + 1}] {dep.dst:<24}{cyan dep.src}{yellow tag}"

    echo ""
    run "cloc --vcs=git"

