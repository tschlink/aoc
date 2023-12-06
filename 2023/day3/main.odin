package day3

import "core:fmt"
import "core:strings"
import "core:strconv"

import "../../aoc"

SYMBOL_RANGE1_START :: 0x21
SYMBOL_RANGE1_END :: 0x2F

SYMBOL_RANGE2_START :: 0x3A
SYMBOL_RANGE2_END :: 0x40

PERIOD :: 0x2E

Gear :: struct {
    nums: int,
    prod: int,
}

main :: proc() {
    lines := aoc.file2lines("input.txt")
    sidx, eidx := -1, -1

    gear_mappings := make(map[int]Gear)
    defer delete(gear_mappings)

    sum := 0
    for line, lidx in lines {
        for r, ridx in line {
            if r >= '0' && r <= '9' {
                if sidx == -1 {
                    sidx = ridx
                    eidx = ridx
                }
                else do eidx = ridx
            // THIS DOESN'T COVER TRAILING OFF THE LINE!
            } else if sidx >= 0 && eidx > 0 {
                at_symbol, sym, idx := is_adjacent_to_symbol(lidx, sidx, eidx, lines)
                if at_symbol {
                    num, ok := strconv.parse_int(line[sidx:eidx+1])
                    if !ok do fmt.panicf("Failed to parse number %v", line[sidx:eidx+1])
                    sum += num

                    if sym == '*' {
                        if idx not_in gear_mappings {
                            gear_mappings[idx] = {0, 1}
                        }
                        g := gear_mappings[idx]
                        g.nums += 1
                        g.prod *= num
                        gear_mappings[idx] = g
                    }
                }
                // reset indices after we're done processing the number
                sidx = -1
                eidx = -1
            } else {
                continue
            }
        }
        if sidx >= 0 && eidx > 0 {
            at_symbol, sym, idx := is_adjacent_to_symbol(lidx, sidx, eidx, lines)
            if at_symbol {
                num, ok := strconv.parse_int(line[sidx:eidx+1])
                if !ok do fmt.panicf("Failed to parse number %v", line[sidx:eidx+1])
                sum += num

                if sym == '*' {
                    if idx not_in gear_mappings {
                        gear_mappings[idx] = {0, 1}
                    }
                    g := gear_mappings[idx]
                    g.nums += 1
                    g.prod *= num
                    gear_mappings[idx] = g
                }
            }
            // reset indices after we're done processing the number
            sidx = -1
            eidx = -1
        }
    }

    fmt.println(sum)

    gear_sum := 0
    for k, v in gear_mappings {
        if v.nums == 2 do gear_sum += v.prod
    }
    fmt.println(gear_mappings)
    fmt.println(gear_sum)
}

is_adjacent_to_symbol :: proc(line, sidx, eidx: int, lines: []string) -> (bool, u8, int) {
    for i in -1..=1 {
        // skip OOB lines
        if line + i < 0 do continue
        if line + i > len(lines) - 1 do continue

        for j in sidx-1 ..= eidx + 1 {
            if j < 0 || j > len(lines[line + i]) - 1 do continue

            r := lines[line + i][j]

            switch r {
                case '.': continue // exclude dot since it's part of the ranges
                case SYMBOL_RANGE1_START..=SYMBOL_RANGE1_END:
                    fallthrough
                case SYMBOL_RANGE2_START..=SYMBOL_RANGE2_END:
                return true, r, len(lines[0]) * (line + i) + j
                case: continue
            }
        }
    }
    return false, 0, -1
}
