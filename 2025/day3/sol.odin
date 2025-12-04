package day3

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

import "../lib"

main2 :: proc() {
    lines := lib.read_lines("input.txt")

    sum := 0

    for line in lines {
        digits: [2]u8 = {0, 0}
        first_dig_idx := 0
        for c, idx in line[:len(line)-1] {
            if u8(c) > digits[0] {
                digits[0] = u8(c)
                first_dig_idx = idx
            }
        }

        for c in line[first_dig_idx+1:] {
            if u8(c) > digits[1] {
                digits[1] = u8(c)
            }
        }

        num, ok := strconv.parse_int(string(digits[:]))
        sum += num
    }
    fmt.println(sum)
}

main :: proc() {
    lines := lib.read_lines("input.txt")

    sum := 0

    for line in lines {
        digits := make([]u8, 12)
        window_sz := len(line) - 11

        window_offset := 0
        for i in 0..<12 {
            for j := window_offset; j < window_sz; j += 1 {
                if u8(line[i+j]) > digits[i] {
                    digits[i] = u8(line[i+j])
                    window_offset = j
                }
            }
        }
        num, ok := strconv.parse_int(string(digits))
        fmt.println(line, num)
        sum += num
    }
    fmt.println(sum)
}
