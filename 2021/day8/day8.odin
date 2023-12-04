package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:math"

input_file :: "input.txt"

main :: proc() {
    part2_good()
}

part1 :: proc() {
    buf: string = ---
    if tmp_buf, ok := os.read_entire_file(input_file); ok {
        buf = strings.clone_from(tmp_buf)
    }

    all_lines := strings.split(buf, "\n")
    lines := all_lines[:len(all_lines) - 1]

    unique_digit_count := 0
    for l in lines {
        output := strings.split(l, " | ")
        digits := strings.split(output[1], " ")
        for d in digits {
            switch len(d) {
                case 2..4, 7: {
                    unique_digit_count += 1
                }
            }
        }
    }
    fmt.println("Part 1:", unique_digit_count)
}

arr_contains :: proc(arr: []rune, r: rune) -> bool {
    for a in arr {
        if a == r do return true
    }
    return false
}

part2_good :: proc() {
    contains_all :: proc(heap, needles: string, exactly: bool = false) -> bool {
        if exactly && len(heap) != len(needles) do return false
        for n in needles {
            if strings.contains_rune(heap, n) == -1 do return false
        }
        return true
    }

    /*
    2 signals: 1
    3 signals: 7
    4 signals: 4
    5 signals: 2 3 5
    6 signals: 0 6 9
    7 signals: 8
    */

    buf: string = ---
    if tmp_buf, ok := os.read_entire_file(input_file); ok {
        buf = strings.clone_from(tmp_buf)
    }

    all_lines := strings.split(buf, "\n")
    lines := all_lines[:len(all_lines) - 1]

    sum := 0
    for l in lines {
        output  := strings.split(l, " | ")
        signals := strings.split(output[0], " ")
        digits  := strings.split(output[1], " ")
        patterns: [6][dynamic]string
        numbers:  [10]string

        for d in signals {
            append(&patterns[len(d) - 2], d)
        }

        numbers[1] = patterns[0][0]
        numbers[7] = patterns[1][0]
        numbers[4] = patterns[2][0]
        numbers[8] = patterns[5][0]

        // set 3 contains all of 1, 2 and 5 don't
        for p in patterns[3] {
            if contains_all(p, numbers[1]) do numbers[3] = p
        }

        for p in patterns[4] {
            if contains_all(p, numbers[3]) do numbers[9] = p
        }

        for p in patterns[4] {
            if p == numbers[9] do continue
            if contains_all(p, numbers[1]) do numbers[0] = p
        }
        for p in patterns[4] {
            if p == numbers[9] || p == numbers[0] do continue
            numbers[6] = p
            break
        }

        for p in patterns[3] {
            if contains_all(numbers[6], p) {
                numbers[5] = p
                break
            }
        }
        for p in patterns[3] {
            if p == numbers[5] || p == numbers[3] do continue
            numbers[2] = p
            break
        }

        fmt.println(numbers)
        output_number := 0
        for d, idx in digits {
            num: int
            for p, i in numbers {
                if contains_all(d, p, true) {
                    fmt.println("Digit", idx, "=", i)
                    num = i
                    break
                }
            }
            output_number += num * int(math.pow(10.0, f32(3.0-idx)))
        }
        fmt.println(output_number)
        sum += output_number
    }
    fmt.println(sum)
}
part2 :: proc() {
    // assumes s2 longer than s1
    diff_pattern :: proc(s1, s2: string, diff_left: bool = true) -> []rune {
        fmt.println("Diffing:", s1, s2)
        diff := make([dynamic]rune)
        idx := 0
        for r in s2 {
            if strings.contains_rune(s1, r) == -1 {
                //fmt.println(r, "not present in", s1)
                append(&diff, r)
            }
        }
        if diff_left {
            for r in s1 {
                if strings.contains_rune(s2, r) == -1 {
                    //fmt.println(r, "not present in", s2)
                    append(&diff, r)
                }
            }
        }
        return diff[:]
    }

    buf: string = ---
    if tmp_buf, ok := os.read_entire_file(input_file); ok {
        buf = strings.clone_from(tmp_buf)
    }

    all_lines := strings.split(buf, "\n")
    lines := all_lines[:len(all_lines) - 1]

    sum := 0
    for l in lines {
        output := strings.split(l, " | ")
        signals := strings.split(output[0], " ")
        digits := strings.split(output[1], " ")
        patterns: [6][dynamic]string
        segments: [7]rune
        numbers: [10]string

        for d in signals {
            append(&patterns[len(d) - 2], d)
        }
        fmt.println(patterns)

        // find segment 1
        one := patterns[0][0]
        numbers[1] = one
        seven := patterns[1][0]
        numbers[7] = seven

        assert(len(patterns[5]) == 1, "more than one 8 pattern")
        numbers[8] = patterns[5][0]

        {
            diff := diff_pattern(one, seven)
            assert(len(diff) == 1, "one-seven diff not length 1")
            segments[0] = diff_pattern(one, seven)[0]
        }

        // find segment 7 by diffing 4 against 6 segment numbers, trying to
        // find 9, and getting the bottom segment that way
        assert(len(patterns[2]) == 1, "more than one 4 pattern found")
        numbers[4] = patterns[2][0]
        for p in patterns[4] {
            diff := diff_pattern(numbers[4], p)
            // only 9 matches this
            if len(diff) == 2 {
                // found 9
                numbers[9] = p
                fmt.println(diff, segments[0])
                if diff[0] != segments[0] {
                    segments[6] = diff[0]
                } else {
                    segments[6] = diff[1]
                }
            }
        }

        // built pattern from known segments and 4 to get segment 5
        seg5_search_pattern := fmt.aprintf("%s%r%r", numbers[4], segments[0], segments[6])
        {
            // diff against 8 to get lower left segment
            diff := diff_pattern(numbers[8], seg5_search_pattern)
            assert(len(diff) == 1, "bad segment 5 diff")
            segments[4] = diff[0]
        }

        // find 2, since it's the only 5 segment digit that contains segment 5
        for p in patterns[3] {
            if strings.contains_rune(p, segments[4]) != -1 {
                numbers[2] = p
                break
            }
        }

        // diff 2 and 1 to get segment 6
        {
            diff := diff_pattern(numbers[2], numbers[1], false)
            assert(len(diff) == 1, "bad 2, 1 diff result")
            segments[5] = diff[0]
        }

        // diff 2 against 6-segment numbers to get 0 and 6
        for p in patterns[4] {
            if p == numbers[9] do continue
            diff := diff_pattern(numbers[2], p)
            fmt.println(len(diff))
        }
        fmt.println(segments)
        fmt.println(numbers)
    }
    fmt.println("Part 2:", sum)
}
