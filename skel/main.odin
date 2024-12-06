package advent

import "aoc:txt"
import "core:fmt"

main :: proc() {
    lines, str := txt.get_lines("example.txt")
    defer {
        delete(lines)
        delete(str)
    }
    fmt.println(lines)
}
