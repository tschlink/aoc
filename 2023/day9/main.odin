package day9

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    sum := 0
    sum_back := 0
    for line in lines {
        if line == "" do continue

        nums := strings.split(line, " ")
        seq := make([]int, len(nums))
        for num, i in nums {
            n, ok := strconv.parse_int(num)
            if !ok do panic("Number parse error")
            seq[i] = n
        }
        res := extrapolate(seq)
        res_back := extrapolate_back(seq)
        fmt.println(res_back)
        sum += res
        sum_back += res_back
    }

    fmt.println(sum)
    fmt.println(sum_back)
}

extrapolate :: proc(seq: []int) -> int {
    nseq := make([]int, len(seq) - 1)
    for i in 0..<len(seq) - 1 {
        nseq[i] = seq[i + 1] - seq[i]
    }
    if all_zero(nseq) {
        return seq[len(seq)-1]
    } else {
        return seq[len(seq)-1] + extrapolate(nseq)
    }
}

extrapolate_back :: proc(seq: []int) -> int {
    nseq := make([]int, len(seq) - 1)
    for i in 0..<len(seq) - 1 {
        nseq[i] = seq[i + 1] - seq[i]
    }

    if all_zero(nseq) {
        return seq[0]
    } else {
        return seq[0] - extrapolate_back(nseq)
    }
}

all_zero :: proc(seq: []int) -> bool {
    for n in seq do if n != 0 do return false
    return true
}
