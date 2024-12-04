package advent

import "aoc:txt"
import "core:fmt"
import "core:strings"
import "core:unicode/utf8"

Dir :: struct { x, y: int }
dirs := [9]Dir {
    {-1, -1}, // 1
    { 0, -1}, // 2
    { 1, -1}, // 3
    {-1,  0}, // 4
    { 0,  0}, // 5
    { 1,  0}, // 6
    {-1,  1}, // 7
    { 0,  1}, // 8
    { 1,  1}, // 9
}

main :: proc() {
    lines, str := txt.get_lines("input.txt")

    words := make([][]rune, len(lines))
    for l, i in lines {
        words[i] = make([]rune, len(l))
        for r, j in l do words[i][j] = r
    }

    sum := 0

    // part 1
    for w, y in words {
        for r, x in w {
            for i in 0..<9 do if i != 4 && check_letters(words, x, y, i) do sum += 1
        }
    }
    fmt.println(sum)

    sum = 0
    // part 2
    for w, y in words {
        for r, x in w {
            if x == 0 || x > len(w) - 2 || y == 0 || y > len(words) - 2 do continue
            if words[y][x] == 'A' do if is_x_mas(words, x, y) do sum += 1
        }
    }
    fmt.println(sum)
}

check_letters :: proc(words: [][]rune, x, y: int, d: int) -> bool {
    assert(d < 9 && d != 4)

    dir := dirs[d]
    if dir.x == -1 && x < 3                 do return false
    if dir.x ==  1 && x > len(words[0]) - 4 do return false
    if dir.y == -1 && y < 3                 do return false
    if dir.y ==  1 && y > len(words) - 4    do return false
    xmas := "XMAS"

    match := true
    for i in 0..<4 {
        if words[i * dir.y + y][i * dir.x + x] != cast(rune)xmas[i] do match = false
    }

    return match
}

is_x_mas :: proc(words: [][]rune, x, y: int) -> bool {
    patterns :: [4]string{
        // all possible cross patterns
        "SMSM", "MSMS", "MMSS", "SSMM"
    }

    str := make([]rune, 4)
    str[0] = words[y - 1][x - 1]
    str[1] = words[y - 1][x + 1]
    str[2] = words[y + 1][x - 1]
    str[3] = words[y + 1][x + 1]

    pattern := utf8.runes_to_string(str)
    fmt.println(pattern)

    for p in patterns do if p == pattern do return true
    return false
}
