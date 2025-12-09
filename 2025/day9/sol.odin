package day9

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:c"

import "../lib"

import rl "vendor:raylib"

Point :: struct {
    x, y: int,
}

Edge :: struct {
    p1, p2: Point,
}

Dir :: enum{VERTICAL, HORIZONTAL}

main :: proc() {
    lines := lib.read_lines("input.txt")

    tiles := make([dynamic]Point, 0, len(lines))

    for line in lines {
        t := strings.split(line, ",")
        n1, ok1 := strconv.parse_int(t[0])
        n2, ok2 := strconv.parse_int(t[1])

        if !ok1 || !ok2 do panic("Failed to parse number")

        append(&tiles, Point{n1, n2})

    }

    // part 2 prep
    polygon := make(map[Edge]Dir)

    for i := 1; i < len(tiles); i += 1 {
        p1 := tiles[i-1]
        p2 := tiles[i]
        dir := .VERTICAL if p1.x == p2.x else .HORIZONTAL
        polygon[Edge{tiles[i-1], tiles[i]}] = dir
    }
    polygon[Edge{tiles[0], tiles[len(tiles)-1]}] = 0

    max_area := 0
    max_inside_area := 0

    for tile, i in tiles {
        for other, j in tiles {
            if i == j do continue
            a := rect_area(tile, other)
            max_area = max(max_area, a)

            if check_box_viable(tile, other) do max_inside_area := max(max_inside_area, a)
        }
    }
    fmt.println("Max area:", max_area)
    fmt.println("Max inside area:", max_inside_area)

}

/*
....................
.........#XXXX#.....
.........X....X.....
.#XXXXXXX#....X.....
.X............X.....
.X............X.....
.X.....#XXX#..#.....
.X.....X...X..X.....
.X.....X...X..X.....
.#XXXXX#...#XXX.....
....................
*/
check_box_viable :: proc(p1, p2: Point, map[Edge]u8) -> u8 {
    
}

rect_area :: proc(p1, p2: Point) -> int {
    x1 := min(p1.x, p2.x)
    y1 := min(p1.y, p2.y)
    x2 := max(p1.x, p2.x)
    y2 := max(p1.y, p2.y)

    w := x2 - x1 + 1
    h := y2 - y1 + 1

    return w * h
}

edge_intersect :: proc(coord: int, dir: Dir, e: Edge) -> bool {
    switch(dir) {
        case .VERTICAL:
            if e.p1.x == e.p2.x {
                return true if e.p1.x == coord else false
            }
            p1 := e.p1
            p2 := e.p2
            if p1.y > p2.y do p1, p2 = p2, p1

        case .HORIZONTAL:
    }
}

draw :: proc(points: []Point) -> (p1, p2: Point) {
    tiles := make(map[Point]u8)

    x1 := min(points[0].x, max(int))
    y1 := min(points[0].y, max(int))
    x2 := max(points[0].x, 0)
    y2 := max(points[0].y, 0)

    for i := 1; i < len(points); i += 1 {
        p := points[i]
        x1 = min(p.x, x1)
        y1 = min(p.y, y1)
        x2 = max(p.x, x2)
        y2 = max(p.y, y2)

        p1 := points[i-1]
        p2 := points[i]

        if p1.x == p2.x {
            if p1.y > p2.y do p1, p2 = p2, p1
            for y in p1.y+1..<p2.y do tiles[Point{p1.x, y}] = 1
        } else if p1.y == p2.y {
            if p1.x > p2.x do p1, p2 = p2, p1
            for x in p1.x+1..<p2.x do tiles[Point{x, p1.y}] = 1
        }

        tiles[p1] = 2
        tiles[p2] = 2
    }

    /*
    for y in y1-2..=y2 + 2 {
        for x in x1-2..=x2 + 2 {
            v, ok := tiles[Point{x,y}]
            if !ok do fmt.print(".")
            else if v == 1 do fmt.print("X")
            else if v == 2 do fmt.print("#")
        }
        fmt.println()
    }
    */

    return Point{x1, y1}, Point{x2, y2}
}

drawRL :: proc(topLeft, bottomRight: Point, points: []Point) {
    for i in 0..<len(points)-1 {
        p1 := points[i]
        p2 := points[i+1]

        rl.DrawLine(c.int(p1.x - topLeft.x),
                    c.int(p1.y - topLeft.y),
                    c.int(p2.x - topLeft.x),
                    c.int(p2.y - topLeft.y),
                    rl.BLACK)
    }
}
