# This file is a part of NimG. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License version 3 only.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

from std/strformat import `&`
export `&`

proc red*    (s: string): string = "\e[31m" & s & "\e[0m"
proc green*  (s: string): string = "\e[32m" & s & "\e[0m"
proc yellow* (s: string): string = "\e[33m" & s & "\e[0m"
proc blue*   (s: string): string = "\e[34m" & s & "\e[0m"
proc magenta*(s: string): string = "\e[35m" & s & "\e[0m"
proc cyan*   (s: string): string = "\e[36m" & s & "\e[0m"

