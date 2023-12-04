package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

input_file :: "input.txt"

main :: proc() {
    part2()
}

part1 :: proc() {
    buf: string = ---
    if tmp_buf, ok := os.read_entire_file(input_file); ok {
        buf = strings.clone_from(tmp_buf)
    }
    str_pos := strings.split(buf, ",")
    positions := make([]int, len(str_pos))
    min, max := 9999, -1
    for str, i in str_pos {
        if pos, ok := strconv.parse_int(strings.trim(str, "\n")); ok {
            positions[i] = pos
            if pos < min do min = pos
            if pos > max do max = pos
        }
    }

    assert(min < max, "minimum pos is not smaller than maxumum pos!")
    optimal_pos, fuel := -1, 1_000_000
    for pos in min..max {
        sum := 0
        for p in positions {
            sum += abs(p - pos)
        }
        if sum < fuel {
            optimal_pos = pos
            fuel = sum
        }
    }

    fmt.println("Part 1: position ->", optimal_pos, ", fuel use ->", fuel)
}

part2 :: proc() {
    linear_sum :: proc(max: int) -> (sum: int) {
        sum = 0
        for i in 1..max do sum += i
        return
    }
    buf: string = ---
    if tmp_buf, ok := os.read_entire_file(input_file); ok {
        buf = strings.clone_from(tmp_buf)
    }
    str_pos := strings.split(buf, ",")
    positions := make([]int, len(str_pos))
    min, max := 9999, -1
    for str, i in str_pos {
        if pos, ok := strconv.parse_int(strings.trim(str, "\n")); ok {
            positions[i] = pos
            if pos < min do min = pos
            if pos > max do max = pos
        }
    }

    assert(min < max, "minimum pos is not smaller than maxumum pos!")
    optimal_pos, fuel := -1, 1_000_000_000_000
    for pos in min..max {
        sum := 0
        for p in positions {
            sum += linear_sum(abs(p - pos))
        }
        if sum < fuel {
            optimal_pos = pos
            fuel = sum
        }
    }

    fmt.println("Part 2: position ->", optimal_pos, ", fuel use ->", fuel)
}
