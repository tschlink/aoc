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

    tiles := make([dynamic]Point, 0, len(lines) + 1)

    for line in lines {
        t := strings.split(line, ",")
        n1, ok1 := strconv.parse_int(t[0])
        n2, ok2 := strconv.parse_int(t[1])

        if !ok1 || !ok2 do panic("Failed to parse number")

        append(&tiles, Point{n1, n2})
    }

    append(&tiles, tiles[0]) // close polygon

    // part 2 prep
    verticals := make([dynamic]Edge)
    horizontals := make([dynamic]Edge)

    for i := 0; i < len(tiles) - 1; i += 1 {
        p1 := tiles[i]
        p2 := tiles[i + 1]
        dir: Dir = .VERTICAL if p1.x == p2.x else .HORIZONTAL
        switch dir {
            case .VERTICAL:
                if p1.y > p2.y do p1, p2 = p2, p1
                e := Edge{p1, p2}
                append(&verticals, e)
            case .HORIZONTAL:
                if p1.x > p2.x do p1, p2 = p2, p1
                e := Edge{p1, p2}
                append(&horizontals, e)
        }
    }

    // TODO: Prune tiles that aren't corners (i.e. inline edges)

    max_area := 0
    max_inside_area := 0

    for tile, i in tiles {
        for other, j in tiles {
            if i == j do continue
            a := rect_area(tile, other)
            max_area = max(max_area, a)

            if check_box_viable(tile, other, verticals[:], horizontals[:], tiles[:]) {
                max_inside_area = max(max_inside_area, a)
            }
        }
    }
    fmt.println("Max area:", max_area)
    fmt.println("Max inside area:", max_inside_area)

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
check_box_viable :: proc(p1, p2: Point, verticals, horizontals:[]Edge, poly: []Point) -> bool {
    xmin := min(p1.x, p2.x)
    xmax := max(p1.x, p2.x)
    ymin := min(p1.y, p2.y)
    ymax := max(p1.y, p2.y)

    for v in verticals {
        assert(v.p1.x == v.p2.x)
        assert(v.p1.y < v.p2.y)
        x := v.p1.x
        y1 := v.p1.y
        y2 := v.p2.y

        if x > xmin && x < xmax {
            start := max(ymin, y1)
            end   := min(ymax, y2)
            if start < end do return false
        }
    }
    for h in horizontals {
        assert(h.p1.y == h.p2.y)
        assert(h.p1.x < h.p2.x)
        y := h.p1.y
        x1 := h.p1.x
        x2 := h.p2.x

        if y > ymin && y < ymax {
            start := max(xmin, x1)
            end   := min(xmax, x2)
            if start < end do return false
        }
    }

    // add 0.5 to avoid edge cases
    testx := f64(xmin) + 0.5
    testy := f64(ymin) + 0.5

    inside := false
    for i in 0..<len(poly) - 1 {
        v1, v2 := poly[i], poly[i+1]
        x1, y1 := f64(v1.x), f64(v1.y)
        x2, y2 := f64(v2.x), f64(v2.y)

        // Check if horizontal ray from test point crosses this edge
        // TODO: check all possible cases
        if (testy < y1) != (testy < y2) {
            // Calculate x coord where ray intersects the edge
            // TODO explain. reverse-engineer!
            intersect_x := (x2 - x1) * (testy - y1) / (y2 - y1) + x1

            // if intersection is to the right of test point, toggle inside/outside
            if testx < intersect_x do inside = !inside
        }
    }
    return inside
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
