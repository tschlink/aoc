package day8

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"

import "../lib"

Box :: struct {
    x, y, z: int,
}

Edge :: struct {
    b1, b2: int, //index
}

Distance :: struct {
    dist: f64,
    edge: Edge,
}

main :: proc() {

    lines := lib.read_lines("input.txt")

    boxes := make([dynamic]Box, 0, len(lines))

    for line in lines {
        values := strings.split(line, ",")

        n1, ok1 := strconv.parse_int(values[0])
        n2, ok2 := strconv.parse_int(values[1])
        n3, ok3 := strconv.parse_int(values[2])
        if !ok1 || !ok2 || !ok3 do panic("Failed to parse numbers")

        box := Box{ n1, n2, n3 }

        append(&boxes, box)
    }

    distances := make([dynamic]Distance)

    for i := 0; i < len(boxes) - 1; i += 1 {
        for j := i + 1; j < len(boxes); j += 1 {
            assert(i != j)

            e := Edge{i, j}
            dist := euclidian_distance(boxes[i], boxes[j])

            append(&distances, Distance{dist, e})
        }
    }

    slice.sort_by(distances[:], proc(o, other: Distance) -> bool {return o.dist < other.dist})

    // need one empty bag to get the loop started
    circuits := make([dynamic][dynamic]int, 1, 1)

    res := -1
    outer: for i in 0..<len(distances) {
        d := distances[i]
        e := d.edge

        first_found_idx  := -1
        second_found_idx := -1
        for &bag, bidx in circuits {

            first_found := false
            second_found := false

            for box in bag {
                if box == e.b1 {
                    first_found = true
                    first_found_idx = bidx
                }
                if box == e.b2 {
                    second_found = true
                    second_found_idx = bidx
                }
            }

            // connection already exists, nothing to do
            if first_found && second_found do continue outer
        }

        if first_found_idx >= 0 && second_found_idx < 0 {
            append(&circuits[first_found_idx], e.b2)

            if len(circuits[first_found_idx]) == len(boxes) {
                res = boxes[e.b1].x * boxes[e.b2].x
                break outer
            }

            continue outer
        } else if second_found_idx >= 0 && first_found_idx < 0 {
            append(&circuits[second_found_idx], e.b1)

            if len(circuits[second_found_idx]) == len(boxes) {
                res = boxes[e.b1].x * boxes[e.b2].x
                break outer
            }

            continue outer
        } else  if first_found_idx > 0 && second_found_idx > 0 {
            // found two circuites connected by the current edge
            c1 := &circuits[first_found_idx]
            c2 := circuits[second_found_idx]

            append_elems(c1, ..c2[:])
            unordered_remove(&circuits, second_found_idx)

            if len(c1) == len(boxes) {
                res = boxes[e.b1].x * boxes[e.b2].x
                break outer
            }
            continue outer
        } else {
            // create new circuit
            new_bag := make([dynamic]int)
            append(&new_bag, e.b1)
            append(&new_bag, e.b2)
            append(&circuits, new_bag)
        }
    }

    assert(res != -1)
    fmt.println(res)

    /* part 1
    slice.sort_by(circuits[:], proc(a, b:[dynamic]int) -> bool {return len(a) > len(b)})

    prod := 1

    for c in circuits[0:3] do prod *= len(c)
    fmt.println(prod)
    */
}

euclidian_distance :: proc(b1, b2: Box) -> f64 {
    a := math.pow(f64(b1.x) - f64(b2.x), 2)
    b := math.pow(f64(b1.y) - f64(b2.y), 2)
    c := math.pow(f64(b1.z) - f64(b2.z), 2)
    return math.sqrt(a + b + c)
}
