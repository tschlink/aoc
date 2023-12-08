package day8

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

Node :: struct {
    left: string,
    right: string,
}

main :: proc() {
    part1()
    part2()
}

part1 :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    directions := lines[0]
    assert(lines[1] == "")

    nodes := make(map[string]^Node)

    for line in lines[2:] {
        if line == "" do continue

        name, n := split_line(line)
        nodes[name] = n
    }

    done := false
    current_node := "AAA"
    steps := 0

    // repeat until done
    for !done do for d in directions {
        // early exit
        if done do break

        switch d {
            case 'L':
            current_node = nodes[current_node].left
            case 'R':
            current_node = nodes[current_node].right
            case: panic("Illegal direction")
        }

        steps += 1

        if current_node == "ZZZ" do done = true
    }

    fmt.println(steps)


}

part2 :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    directions := lines[0]
    assert(lines[1] == "")

    nodes := make(map[string]^Node)

    for line in lines[2:] {
        if line == "" do continue

        name, n := split_line(line)
        nodes[name] = n
    }

    start_nodes := make([dynamic]string)
    defer delete(start_nodes)

    for k,v in nodes {
        if k[2] == 'A' do append(&start_nodes, k)
    }

    res := 1
    for s in start_nodes {
        steps := get_loop_size(s, directions, nodes)
        res = lcm(steps, res)
    }
    fmt.println(res)

}

get_loop_size :: proc(start: string, directions: string, nodes: map[string]^Node) -> int {
    Visit :: struct {node: string, period: int}
    visited := make([dynamic]Visit)
    steps := 0
    current := start
    for {
        dir := directions[steps % len(directions)]
        if current[2] == 'Z' {
            if slice.contains(visited[:], Visit{current, steps%len(directions)}) do break
            else do append(&visited, Visit{current, steps%len(directions)})
        }

        if dir == 'L' do current = nodes[current].left
        else do current = nodes[current].right
        steps += 1
    }

    return steps
}

gcd :: proc(a, b: int) -> int {
    a, b := a, b
    for b != 0 {
        a, b = b, a%b
    }
    return a
}

lcm :: proc(a, b: int) -> int {
    return a * b / gcd(a, b)
}

make_node :: proc(left, right: string) -> ^Node {
    n := new(Node)
    n.left = left
    n.right = right
    return n
}

split_line :: proc(line: string) -> (string, ^Node) {
    split := strings.split(line, " = ")
    children := strings.split(split[1], ", ")
    return split[0], make_node(children[0][1:], children[1][:3])
}
