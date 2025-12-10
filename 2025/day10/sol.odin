package day10

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

import "core:testing"

import "../lib"

Machine :: struct {
    lights: []bool,
    buttons: [][]int,
    joltags: []int,
}

MAX_RECURSION_DEPTH :: 8

main :: proc() {

    lines := lib.read_lines("example.txt")
    defer delete(lines)

    machines := parse_input(lines)
    lib.print_array(machines)

    sum := 0
    for machine in machines {
        light_state := make([]bool, len(machine.lights))
        defer delete(light_state)

        pressed := make([dynamic][]int, 0, MAX_RECURSION_DEPTH)
        defer delete(pressed)

        shortest, ok := toggle_lights_rec(light_state, machine.lights, machine.buttons, 1, &pressed)
        if !ok do panic("failed to find valid sequence")

        sum += shortest
        fmt.println(shortest)
    }
    fmt.println("sum", sum)
}


toggle_lights_rec :: proc(state, target: []bool, buttons: [][]int, depth: int, history: ^[dynamic][]int) -> (int, bool) {
    if depth >= MAX_RECURSION_DEPTH do return -1, false

    for b in buttons {
        apply_button(state, b)
        append(history, b)
        if slice.equal(state, target) {
            fmt.println(history, depth)
            return depth, true
        }
        // revert and try next
        unordered_remove(history, len(history)-1)
        apply_button(state, b)
    }

    shortest := max(int)
    sol_found := false
    for b in buttons {
        apply_button(state, b)
        append(history, b)
        d, ok := toggle_lights_rec(state, target, buttons, depth + 1, history)
        if ok {
            sol_found = true
            shortest = min(shortest, d)
            unordered_remove(history, len(history)-1)
        }
        unordered_remove(history, len(history)-1)
        apply_button(state, b)
    }

    return shortest, sol_found

}

apply_button :: proc(lights: []bool, button: []int) {
    for i in button {
        assert(i < len(lights))
        lights[i] = !lights[i]
    }
}

parse_input :: proc(lines: []string) -> []Machine {
    machines := make([]Machine, len(lines))
    for i in 0..<len(lines) {
        line := lines[i]

        data := strings.split(line, " ")
        assert(len(data) >= 3)

        light_data := data[0]
        assert(light_data[0] == '[' && light_data[len(light_data)-1] == ']')

        lights := make([]bool, len(light_data) - 2)
        for r, i in light_data[1:len(light_data)-1] {
            lights[i] = true if r == '#' else false
        }

        button_data := data[1:len(data) - 1]
        buttons := make([][]int, len(button_data))

        for b, i in button_data {
            assert(b[0] == '(' && b[len(b)-1] == ')')
            numbers_s := strings.split(b[1:len(b) - 1], ",")
            numbers := make([]int, len(numbers_s))
            for n, j in numbers_s {
                light_number, ok := strconv.parse_int(n)
                if !ok do panic("Failed to parse button number")
                numbers[j] = light_number
            }
            buttons[i] = numbers
        }

        jolt_data := data[len(data)-1]
        assert(jolt_data[0] == '{' && jolt_data[len(jolt_data)-1] == '}')

        jolt_s := strings.split(jolt_data[1:len(jolt_data)-1], ",")
        joltags := make([]int, len(jolt_s))
        for j, i in jolt_s {
            j_s, ok := strconv.parse_int(j)
            if !ok do panic("Failed to parse joltage number")
            joltags[i] = j_s
        }

        machines[i] = Machine{lights, buttons, joltags}
    }
    return machines
}
