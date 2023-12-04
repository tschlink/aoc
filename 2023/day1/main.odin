package day1

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    part1()
    part2()
}

part1 :: proc() {

    input, ok := os.read_entire_file("input.txt")
    defer delete(input)
    lines := strings.split_lines(string(input))
    defer delete(lines)

    sum := 0
    for line in lines {
        val := 0
        num: int
        for c in line {
            if c >= '0' && c <= '9' {
                num = int(c - '0')
                if val == 0 {
                    val += num
                }
            }
        }
        val *= 10
        val += num
        sum += val
    }
    fmt.println(sum)
}

part2 :: proc() {
    digits := map[string]int {
        "one"   = 1,
        "two"   = 2,
        "three" = 3,
        "four"  = 4,
        "five"  = 5,
        "six"   = 6,
        "seven" = 7,
        "eight" = 8,
        "nine"  = 9,
    }

    input, ok := os.read_entire_file("input.txt")
    defer delete(input)
    lines := strings.split_lines(string(input))
    defer delete(lines)

    sum := 0
    for line in lines {
        if line == "" do continue
        nums := make([dynamic]int)
        defer delete(nums)

        f := -1
        f_idx := max(int)
        l := -1
        l_idx := -1

        for k, v in digits {
            idx := strings.index(line, k)
            // find first string digit
            if idx >= 0 && idx < f_idx {
                f = v
                f_idx = idx
            }

            // find last string digit
            idx = strings.last_index(line, k)
            if idx >= 0 && idx > l_idx {
                l = v
                l_idx = idx
            }
        }

        val: int
        num: int
        t_idx: int

        for c, idx in line {
            if c >= '0' && c <= '9' {
                num = int(c - '0')
                t_idx = idx
                if val == 0 { 
                    if idx < f_idx do val += num
                    else do val += f
                }
            }
        }
        // if there were no digits in the string, add first string number
        if val == 0 do val += f

        // check if last digit was from a string
        if t_idx < l_idx do num = l

        val *= 10
        val += num
        sum += val

    }
    fmt.println(sum)
}
