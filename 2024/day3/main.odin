package advent

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
    content, ok := os.read_entire_file("input.txt")
    if !ok do panic("Failed to read input")
    defer delete(content)

    s := string(content)
    instr := s[:]
    sum := 0
    enabled := true
    for i := 0; i < len(instr) - 8; i += 1 {
        c := instr[i]
        r := rune(c)

        if r == 'm' && enabled {
            if !(instr[i + 1:i + 4] == "ul(") do continue
            num, l, rest := eat_num(instr[i + 4:])
            if l == 0 || rest[0] != ',' do continue
            tmp := num
            num, l, rest = eat_num(rest[1:])
            if l == 0 || rest[0] != ')' do continue

            sum += tmp * num
        }
        if r == 'd' {
            //fmt.println(instr[i:i+4],instr[i:i+7])
            if instr[i:i+4] == "do()" do enabled = true
            if instr[i:i+7] == "don't()" do enabled = false
        }
    }
    fmt.println(sum)
}

eat_num :: proc(str: string) -> (int, int, string) {
    end_idx := 0
    for r in str {
        if r >= '0' && r <= '9' {
            end_idx += 1
        } else {
            break
        }
    }
    num, ok := strconv.parse_int(str[:end_idx])
    if !ok do panic("Failed to parse number. Programming error!")
    return num, end_idx, str[end_idx:]
}
