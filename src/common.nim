# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import std/[sugar, with, enumerate], util
from std/os        import `/`
from std/strformat import `&`
export sugar, with, enumerate, `&`, `/`, util

func red*    (s: string): string = &"\e[31m{s}\e[0m"
func green*  (s: string): string = &"\e[32m{s}\e[0m"
func yellow* (s: string): string = &"\e[33m{s}\e[0m"
func blue*   (s: string): string = &"\e[34m{s}\e[0m"
func magenta*(s: string): string = &"\e[35m{s}\e[0m"
func cyan*   (s: string): string = &"\e[36m{s}\e[0m"

proc error*  (msg: string) = echo red    &"Error: {msg}"
proc warning*(msg: string) = echo yellow &"Warning: {msg}"
proc info*   (msg: string) = echo        &"{msg}"

func bytes_to_string*(bytes: int): string =
    if bytes >= 1024*1024:
        &"{bytes / 1024 / 1024:.1f}MB"
    elif bytes >= 1024:
        &"{bytes / 1024:.1f}kB"
    else:
        &"{bytes}B"

