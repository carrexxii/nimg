import std/[parseopt, streams]
from std/os import get_current_dir, extract_filename, `/`
from std/sequtils import foldl
from std/strformat import fmt
import nai

let cwd = get_current_dir()

proc write_help() =
    echo "Usage:"
    echo "    naic file [options]\n"

    echo "Options: (opt:VAL or opt=VAL)"
    echo "    -i, --input:PATH        Explicitly define an input file"
    echo "    -o, --output:PATH       Define the output path (defaults to current directory)"
    echo "    -v, --verbose           Output extra information about the file being compiled"

    echo "\nSupported formats:"
    echo fmt"""{foldl(get_extension_list(), a & " " & b, "    ")}"""

    quit 0

proc check_duplicate(val, kind: string) =
    if val != "":
        echo fmt"Error: duplicate inputs provided for '{kind}'"
        quit 1

proc check_val(val, opt: string): string =
    if val == "":
        echo fmt"No value provided for '{opt}'"
        quit 1
    result = val

var
    options = init_opt_parser()
    output : string = cwd
    input  : string = ""
    verbose: bool = false
for kind, key, val in get_opt options:
    case kind
    of cmdLongOption, cmdShortOption:
        case key
        of "help"   , "h": write_help()
        of "verbose", "v": verbose = true
        of "output" , "o": output = check_val(val, key)
        of "input"  , "i":
            check_duplicate(input, "input")
            input = val
        else:
            echo fmt"Unrecognized option: '{key}'"
            quit 1
    of cmdArgument:
        check_duplicate(input, "input")
        input = if key == "": val else: key
    of cmdEnd:
        discard

if input == "":
    echo "Error: no input file provided"
    write_help()

if output == cwd:
    output = cwd / extract_filename input

var scene = import_file(input, ProcessFlag 0)
if verbose:
    echo fmt"Scene '{scene.name}' ('{input}' -> '{output}')"
    echo fmt"    Meshes     -> {scene.mesh_count}"
    echo fmt"    Materials  -> {scene.material_count}"
    echo fmt"    Animations -> {scene.animation_count}"
    echo fmt"    Textures   -> {scene.texture_count}"
    echo fmt"    Lights     -> {scene.light_count}"
    echo fmt"    Cameras    -> {scene.camera_count}"
    echo fmt"    Skeletons  -> {scene.skeleton_count}"

var file = open_file_stream("test.txt", fmWrite)
output_meshes(scene, file)
close file

free_scene scene
