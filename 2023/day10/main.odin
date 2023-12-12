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
    content, input_ok := os.read_entire_file("input.txt")
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
    s_rep: u8 = 0

    {
        // find replacement for 'S'
        // ugly ugly, but too lazy to find a nicer solution
        n1, n2 := -1, -1
        // 0 = up, 1 = right, 2 = down, 3 = left

        if start.y > 0 {
        s := lines[start.y - 1][start.x]
            if s == '|' || s == '7' || s == 'F' {
                append(&nbors, Vec2{start.x, start.y - 1})
                if n1 == -1 do n1 = 0
                else do n2 = 0
            }
        }
        if start.y < len(lines) - 1 {
        s := lines[start.y + 1][start.x]
            if s == '|' || s == 'L' || s == 'J' {
                append(&nbors, Vec2{start.x, start.y + 1})
                if n1 == -1 do n1 = 2
                else do n2 = 2
            }
        }
        if start.x > 0 {
        s := lines[start.y][start.x - 1]
            if s == '-' || s == 'L' || s == 'F' {
                append(&nbors, Vec2{start.x - 1, start.y})
                if n1 == -1 do n1 = 3
                else do n2 = 3
            }
        }
        if start.x < len(lines[0]) {
        s := lines[start.y][start.x + 1]
            if s == '-' || s == '7' || s == 'J' {
                append(&nbors, Vec2{start.x + 1, start.y})
                if n1 == -1 do n1 = 1
                else do n2 = 1
            }
        }
        assert(len(nbors) == 2)
        assert(n1 != 1 && n2 != -1)
        if n1 > n2 do n1, n2 = n2, n1

        switch {
            case n1 == 0 && n2 == 2: s_rep = '|'
            case n1 == 1 && n2 == 3: s_rep = '-'
            case n1 == 0 && n2 == 1: s_rep = 'L'
            case n1 == 0 && n2 == 3: s_rep = 'J'
            case n1 == 1 && n2 == 2: s_rep = 'F'
            case n1 == 2 && n2 == 3: s_rep = '7'
            case: fmt.panicf("Illegal start nbor config: %d, %d\n", n1, n2)
        }
    }

    fmt.println("Start", start)
    fmt.println("First nbors", nbors)
    fmt.println("----------")

    // Part 1
    steps := 0
    for nbors[0] != nbors[1] {
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

    fmt.println("Original Input")
    print_map(lines[:])
    // remove every pipe piece not on the loop
    remove_pipes(lines, s_rep, visited[:])

    fmt.println("----------")
    fmt.println("Junk pipes removed")
    print_map(lines[:])

    fmt.println("----------")
    fmt.println("I/O marked")
    insides := count_insides(lines[:])
    fmt.println(insides)
}

count_insides :: proc(lines: []string) -> int {
    State :: enum { OUT, IN }
    insides := 0
    for line, j in lines {
        s: State = .OUT
        last_corner: rune = 0x0
        for c in line {
            print_char := true
            switch c {
                case '|':
                    s = (s == .OUT) ? .IN : .OUT
                case '-':
                // skip
                case 'L':
                    last_corner = 'L'
                case 'J':
                    assert(last_corner != 0x0)
                    switch last_corner {
                        case 'L':
                            //s = (s == .OUT) ? .IN : .OUT
                        case 'F':
                            s = (s == .OUT) ? .IN : .OUT
                        case: panic("Weird corner")
                    }
                    last_corner = 0x0
                case '7':
                    assert(last_corner != 0x0)
                    switch last_corner {
                        case 'L':
                            s = (s == .OUT) ? .IN : .OUT
                        case 'F':
                            //s = (s == .OUT) ? .IN : .OUT
                        case: panic("Weird corner")
                    }
                    last_corner = 0x0
                case 'F':
                    last_corner = 'F'
                case '.':
                    print_char = false
                    if s == .IN {
                        insides += 1
                        fmt.print("I")
                    } else do fmt.print("O")
            }
            if print_char do fmt.print(c)
        }
        fmt.println()
    }
    return insides
}

remove_pipes :: proc(lines: []string, start_replacement: u8, visited: []Vec2) {
    lines := lines
    for line, j in &lines {
        nstr := make([]u8, len(line))
        for r, i in line {
            if r == 'S' {
                nstr[i] = start_replacement
                continue
            }
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
