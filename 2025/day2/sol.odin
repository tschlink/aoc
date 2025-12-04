package day2

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
    content, ok := os.read_entire_file("input.txt")
    if !ok do panic("Could not read input")
    input := string(content)

    ranges := strings.split(input[:len(input) - 1], ",")
    sum := 0

    for r in ranges {
        ids := strings.split(r, "-")

        start, sok := strconv.parse_int(ids[0])
        end,   eok := strconv.parse_int(ids[1])

        if !sok || !eok do fmt.panicf("Failed to parse IDs (%v)", ids)
        if start > end  do fmt.panicf("Invalid range %v-%v", start, end)


        for i := start; i <= end; i += 1 {
            if has_any_repeat_seq(i) do sum += i
        }
    }

    fmt.println(sum, "total sum")

}

// part 1
has_one_repeat_seq :: proc(num: int) -> bool {
    str := fmt.aprint(num)
    defer delete(str)

    l := len(str)
    if l % 2 != 0 do return false

    h := l / 2
    for i := 0; i < h; i+= 1 {
        if str[i] != str[i + h] do return false
    }

    return true
}

// part 2
has_any_repeat_seq :: proc(num: int) -> bool {
    str := fmt.aprint(num)
    defer delete(str)


    l := len(str)
    h := l / 2

    // 565656
    // [56]      [56]      [56]
    //  ^         ^         ^
    //  seg[0][0] seg[1][0] seg[2][0]


    loop: for stride := 1; stride <= h; stride += 1 {
        if l % stride != 0 do continue

        seg_count := l / stride

        // check number with current stride
        for i := 1; i < seg_count; i += 1 {
            // per segment
            for j := 0; j < stride; j += 1 {
                // per number in segment
                if str[j] != str[i * stride + j] do continue loop
            }
        }
        return true
    }
    return false
}
