package advent

import "aoc:txt"
import "core:fmt"
import "core:slice"

main :: proc() {
    lines, str := txt.get_lines("input.txt")
    defer {
        delete(lines)
        delete(str)
    }

    w, h := len(lines[0]), len(lines)

    antennae := make(map[u8][dynamic][2]int)
    for l, i in lines {
        for r, j in l {
            r := u8(r)
            if r != '.' {
                _, ok := antennae[r]
                if !ok do antennae[r] = make([dynamic][2]int)
                append(&antennae[r], [2]int{j, i})
            }
        }
    }

    nodes := make([dynamic][2]int)
    for freq, points in antennae {
        for p in points {
            for pt in points {
                if p == pt do continue
                n := calc_nodes(p.x, p.y, pt.x, pt.y)
                n0, n1 := n[0], n[1]
                if n0.x >= 0 && n0.y >= 0 && n0.x < w && n0.y < h do append(&nodes, n[0])
                if n1.x >= 0 && n1.y >= 0 && n1.x < w && n1.y < h do append(&nodes, n[1])
            }
        }
    }

    for y in 0..<h {
        run: for x in 0..<w {
            for n in nodes {
                if n == {x, y} {
                    fmt.print(rune('#'))
                    continue run
                }
            }
            for k, v in antennae {
                for p in v {
                    if p == {x, y} {
                        fmt.print(rune(k))
                        continue run
                    }
                }
            }
            fmt.print('.')
        }
        fmt.println()
    }

    uniq_nodes := make(map[[2]int]bool)
    for n in nodes do uniq_nodes[n] = true
    fmt.println(len(uniq_nodes))

    // part 2
    delete(uniq_nodes)
    uniq_nodes = make(map[[2]int]bool)
    for freq, points in antennae {
        for p in points {
            for pt in points {
                if p == pt do continue
                nodes := calc_nodes2(p.x, p.y, pt.x, pt.y, w, h)
                for n in nodes do uniq_nodes[n] = true
            }
        }
    }


    for y in 0..<h {
        run2: for x in 0..<w {
            for n, _ in uniq_nodes {
                if n == {x, y} {
                    fmt.print(rune('#'))
                    continue run2
                }
            }
            for k, v in antennae {
                for p in v {
                    if p == {x, y} {
                        fmt.print(rune(k))
                        continue run2
                    }
                }
            }
            fmt.print('.')
        }
        fmt.println()
    }

    for n in nodes do uniq_nodes[n] = true
    //fmt.println(uniq_nodes)
    fmt.println(len(uniq_nodes))
}

calc_nodes :: proc(x1, y1, x2, y2: int) -> (res: [2][2]int) {
    dx := x1 - x2
    dy := y1 - y2

    res[0] = {x1 + dx, y1 + dy}
    res[1] = {x2 - dx, y2 - dy}
    return
}

calc_nodes2 :: proc(x1, y1, x2, y2, w, h: int) -> [][2]int {
    points := make([dynamic][2]int)
    dx := x1 - x2
    dy := y1 - y2

    x1, y1 := x1, y1
    for x1 >= 0 && y1 >= 0 && x1 < w && y1 < h {
        append(&points, [2]int{x1, y1})
        x1, y1 = x1 + dx, y1 + dy
    }
    x2, y2 := x2, y2
    for x2 >= 0 && y2 >= 0 && x2 < w && y2 < h {
        append(&points, [2]int{x2, y2})
        x2, y2 = x2 - dx, y2 - dy
    }
    return points[:]
}
