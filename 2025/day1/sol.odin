package day1

import "../lib"
import "core:fmt"
import "core:strconv"

main1 :: proc() {
    lines := lib.read_lines("example.txt")

    pos := 50
    zeroes := 0

    for line in lines {
        rot := line[0]

        turn, ok := strconv.parse_int(line[1:])
        if !ok do fmt.panicf("Failed to parse number on line '%v'\n", line)

        fmt.printf("%v -> %v ", pos, line)
        if rot == 'L' do pos -= (turn % 100)
        else do pos = (pos + turn) % 100

        fmt.print("->", pos)

        if pos < 0 do pos = 100 + pos
        if pos == 0 do zeroes += 1

        fmt.print(" ->", pos)
        fmt.println()
    }
    fmt.printf("%v zeroes\n", zeroes)
}

main :: proc() {
    lines := lib.read_lines("input.txt")

    pos := 50
    zeroes := 0

    for line in lines {
        rot := line[0]
        old_pos := pos

        turn, ok := strconv.parse_int(line[1:])
        if !ok do fmt.panicf("Failed to parse number on line '%v'\n", line)

        fmt.printf("%v -> %v ", pos, line)
        if rot == 'L' do pos -= turn
        else          do pos += turn

        fmt.print("->", pos)

        if      pos < 0 && old_pos > 0 do zeroes += 1
        else if pos > 0 && old_pos < 0 do zeroes += 1
        else if pos == 0 do zeroes += 1
        zeroes += abs(pos) / 100

        pos = pos %% 100

        fmt.print(" ->", pos)
        fmt.println()
    }
    fmt.printf("%v zeroes hit\n", zeroes)
}
