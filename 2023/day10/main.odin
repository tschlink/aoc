package day10

import "core:os"
import "core:fmt"
import "core:strings"
import "core:slice"

Nbors := map[u8][2]Vec2 {
    '|' = {{ 0, -1},{ 0,  1}},
    '-' = {{-1,  0},{ 1,  0}},
    'L' = {{ 1,  0},{ 0, -1}},
    'J' = {{-1,  0},{ 0, -1}},
    '7' = {{-1,  0},{ 0,  1}},
    'F' = {{ 1,  0},{ 0,  1}},
}

Vec2 :: struct {
    x, y: int,
}

main :: proc() {
    content, input_ok := os.read_entire_file("example2.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    start: Vec2
    visited: [dynamic]Vec2

    out:for line, j in lines {
        if line == "" do continue
        for r, i in line {
            if r == 'S' {
                start = {i, j}
                break out
            }
        }
    }

    append(&visited, start)

    nbors := make([dynamic]Vec2)

    {
        if start.y > 0 {
        s := lines[start.y - 1][start.x]
            if s == '|' || s == '7' || s == 'F' do append(&nbors, Vec2{start.x, start.y - 1})
        }
        if start.y < len(lines) - 1 {
        s := lines[start.y + 1][start.x]
            if s == '|' || s == 'L' || s == 'J' do append(&nbors, Vec2{start.x, start.y + 1})
        }
        if start.x > 0 {
        s := lines[start.y][start.x - 1]
            if s == '-' || s == 'L' || s == 'F' do append(&nbors, Vec2{start.x - 1, start.y})
        }
        if start.x < len(lines[0]) {
        s := lines[start.y][start.x + 1]
            if s == '-' || s == '7' || s == 'J' do append(&nbors, Vec2{start.x + 1, start.y})
        }
        assert(len(nbors) == 2)
    }

    fmt.println("Start", start)
    fmt.println("First nbors", nbors)
    fmt.println("----------")

    // Part 1
    steps := 0
    for nbors[0] != nbors[1] {
        //fmt.println("Step", steps, nbors)
        append(&visited, nbors[0])
        append(&visited, nbors[1])

        nbors[0] = advance(nbors[0], visited[:], lines)
        nbors[1] = advance(nbors[1], visited[:], lines)
        steps += 1
        //fmt.println("----------")
    }
    // +1 because we abort when last node is found
    fmt.println(steps+1)

    // Part 2

    // add last point to list of visited nodes
    append(&visited, nbors[0])

    print_map(lines[:])
    // remove every pipe piece not on the loop
    remove_pipes(lines, visited[:])

    fmt.println("----------")
    print_map(lines[:])
}

count_insides :: proc(lines: []string) {
    State :: enum { OUT, IN }
    insides := 0
    for line, j in lines {
        s: State = .OUT
        for c in line {
            switch c {
                case '|':
                s = (s == .OUT) ? .IN : .OUT
                case '-':
                case 'L':
                case 'J':
                case '7':
                case 'F':
                case '.':
                if s == .IN {
                    insides += 1
                    fmt.print("I")
                } else do fmt.print("O")
            }
        }
        fmt.println()
    }
}

remove_pipes :: proc(lines: []string, visited: []Vec2) {
    lines := lines
    for line, j in &lines {
        nstr := make([]u8, len(line))
        for r, i in line {
            if slice.contains(visited, Vec2{i, j}) do nstr[i] = u8(r)
            else do nstr[i] = '.'
        }
        line = string(nstr)
    }
}

print_map :: proc(lines: []string) {
    for line in lines {
        fmt.println(line)
    }
}

find_neighbors :: proc(p: Vec2, lines: []string) -> [2]Vec2 {
    s := Nbors[lines[p.y][p.x]]
    return {{p.x + s[0].x, p.y + s[0].y},{p.x + s[1].x, p.y + s[1].y}}
}

advance :: proc(p: Vec2, visited: []Vec2, lines: []string) -> Vec2 {
    nbors := find_neighbors(p, lines)

    if !slice.contains(visited, nbors[0]) {
        assert(slice.contains(visited, nbors[1]))
        return nbors[0]
    }
    else {
        assert(slice.contains(visited, nbors[0]))
        return nbors[1]
    }
}
