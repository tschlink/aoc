package advent

import "aoc:txt"
import "core:fmt"

// 0 UP
// 1 RIGHT
// 2 DOWN
// 3 LEFT
Direction :: int
DX := [4][2]int {
    {0, -1}, //UP
    {1,  0}, //RIGHT
    {0,  1}, //DOWN
    {-1, 0}, //LEFT
}

main :: proc() {
    lines, str := txt.get_lines("input.txt")
    defer {
        delete(lines)
        delete(str)
    }

    height := len(lines)
    width  := len(lines[0])

    mappa := make([][]u8, height)
    start: [2]int
    for l, j in lines {
        mappa[j] = make([]u8, width)
        for c, i in l {
            if c == '.' || c == '^' do mappa[j][i] = 0
            if c == '#' do mappa[j][i] = 1
            if c == '^' do start = {i, j}
        }
    }


    visited := make([dynamic][2]int)
    current := start
    current_dir: Direction = 0
    going := true

    // part 1
    for going {
        append(&visited, current)

        dx := DX[current_dir]
        next := [2]int{current.x + dx.x, current.y + dx.y}

        // stop when leaving the map
        if next.x < 0 || next.x >= width || next.y < 0 || next.y >= height {
            going = false
            break
        }

        if mappa[next.y][next.x] == 1 {
            // accept we're going to add the same position twice
            // we de-dupe anyway
            current_dir = (current_dir + 1) % 4
            continue
        }
        current = next
    }

    for i := 0; i < len(visited); i += 1 {
        c := visited[i]
        for j := i + 1; j < len(visited); j += 1 {
            if visited[j] == c do ordered_remove(&visited, j)
        }
    }

    fmt.println(len(visited))

    // part 2
    sum := 0
    fmt.println("checking ~", len(mappa) * len(mappa[0]), "positions")
    for row, y in mappa {
        for _, x in row {
            iter := x + len(mappa) * y
            if mappa[y][x] == 1 || start == {x, y} do continue
            if iter % 100 == 0 do fmt.println("checking iteration", iter)

            mappa[y][x] = 1
            if loops(mappa, start) do sum += 1
            mappa[y][x] = 0
        }
    }
    fmt.println(sum)
}

loops :: proc(mappa: [][]u8, start: [2]int) -> bool {
    height := len(mappa)
    width := len(mappa[0])

    current := start
    current_dir: Direction = 0

    visited := make([dynamic][3]int)
    defer delete(visited)
    append(&visited, [3]int{start.x, start.y, 0})

    for {
        dx := DX[current_dir]
        next := [2]int{current.x + dx.x, current.y + dx.y}

        if next.x < 0 || next.x >= width || next.y < 0 || next.y >= height do return false

        if mappa[next.y][next.x] == 1 {
            current_dir = (current_dir + 1) % 4
            for v in visited do if v == {current.x, current.y, current_dir} do return true
            append(&visited, [3]int{current.x, current.y, current_dir})
        } else {
            current = next
        }
    }
    return false
}

draw_map :: proc(mappa: [][]u8, pos: ^[2]int = nil, dir: Direction = 0) {
    pointer := "^>v<"

    for col, y in mappa {
        for row, x in col {
            if mappa != nil && pos^ == {x, y} {
                fmt.print(rune(pointer[dir]))
            }
            if row == 0 do fmt.print('.')
            else if row == 1 do fmt.print('#')
        }
        fmt.println()
    }
}
