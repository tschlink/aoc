package txt

import "core:os"
import "core:strings"
import "core:strconv"

import "core:fmt"

get_lines :: proc(filepath: string) -> ([]string, string) {
    content, ok := os.read_entire_file(filepath)
    str := string(content)
    lines := strings.split(str, "\n")
    l := len(lines)
    // cut off empty lines at the end
    for lines[l-1] == "" {
        l -= 1
        lines = lines[:l]
    }
    return lines, str
}

split_nums :: proc(str: string, sep: string) -> (numbers: []int, success: bool) {
    nums := strings.split(str, sep)
    sl := make([]int, len(nums))
    for n, i in nums {
        parsed, ok := strconv.parse_int(n)
        if !ok {
            delete(sl)
            success = false
            return
        }
        sl[i] = parsed
    }
    return sl, true
}
