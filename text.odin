package txt

import "core:os"
import "core:strings"

getLines :: proc(filepath: string) -> []string {
    content, ok := os.read_entire_file(filepath)
    if !ok do panic("Could not read file!")
    defer delete(content)
    return strings.split_lines(strings.trim(string(content)))
}
