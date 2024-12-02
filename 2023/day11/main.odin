package day11

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"

Vec2 :: struct { x, y: int }

main :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    empty_rows := make([dynamic]int)
    empty_cols := make([dynamic]int)

    galaxies := make([dynamic]Vec2)

    for line, j in lines {
        if line == "" do continue
        gs_found := false
        for c, i in line {
            if c == '#' {
                append(&galaxies, Vec2{i, j})
                gs_found = true
            }
        }
        if !gs_found do append(&empty_rows, j)
    }

    // find empty cols
    for i in 0..<len(lines[0]) {
        gs_found := false
        for j in 0..<len(lines) - 1 {
            if lines[j][i] == '#' {
                gs_found = true
                break
            }
        }
        if !gs_found do append(&empty_cols, i)
    }


    fmt.println(empty_cols)
    fmt.println(empty_rows)

    switch {
        case true: fallthrough
        case false:
    }
    // add expanded space to galaxy coords
    for g in &galaxies {
        dx := 0
        dy := 0
        for c in empty_cols do if c < g.x do dx += 1
        for r in empty_rows do if r < g.y do dy += 1

        // remove multiplier for part 1 solution
        if dx > 0 do g.x += dx * 999_999
        if dy > 0 do g.y += dy * 999_999
    }

    gnum := len(galaxies)
    sum := 0

    c := 0
    for i := 0; i < gnum - 1; i += 1 {
        for j := i + 1; j < gnum; j += 1 {
            p: [2]Vec2 = {galaxies[i], galaxies[j]}
            sum += manhattan_distance(p[0], p[1])
            c += 1
        }
    }

    fmt.println(sum)
}

manhattan_distance :: proc(p1, p2: Vec2) -> int {
    return abs(p1.x - p2.x) + abs(p1.y - p2.y)
}
