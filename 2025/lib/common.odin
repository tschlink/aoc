package lib

import "core:os"
import "core:strings"
import "core:fmt"

read_lines :: proc(path: string, alloc := context.allocator) -> []string {
    content, ok := os.read_entire_file(path, alloc)
    if !ok do fmt.panicf("Failed to read file %s\n", path)
    lines := strings.split_lines(string(content))

    if lines[len(lines)-1] == "" do lines = lines[:len(lines)-1]

    return lines
}
