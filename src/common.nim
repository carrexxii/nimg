from std/strformat import `&`
export `&`

proc red*    (s: string): string = "\e[31m" & s & "\e[0m"
proc green*  (s: string): string = "\e[32m" & s & "\e[0m"
proc yellow* (s: string): string = "\e[33m" & s & "\e[0m"
proc blue*   (s: string): string = "\e[34m" & s & "\e[0m"
proc magenta*(s: string): string = "\e[35m" & s & "\e[0m"
proc cyan*   (s: string): string = "\e[36m" & s & "\e[0m"
