package day12

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

import test "core:testing"

Record :: struct {
    springs: string,
    sizes: []int,
}

main :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    records := make([dynamic]Record)
    defer for r in records do delete(r.sizes)
    defer delete(records)

    for line in lines {
        if line == "" do continue
        info := strings.split(line, " ")
        size_nums := strings.split(info[1], ",")

        sizes := make([]int, len(size_nums))
        for size, i in size_nums {
            s, ok := strconv.parse_int(size)
            if !ok do panic("Parsing Error: Bad size")
            sizes[i] = s
        }

        append(&records, Record{info[0], sizes})
    }

    sum := 0
    for r in records {
        sum += count_permutations(r)
    }

    // clean up all temp allocated strings
    free_all(context.temp_allocator)

    fmt.println(sum)
}

count_permutations :: proc(r: Record) -> int {
    qm_count: uint = 0
    for c in r.springs do if c == '?' do qm_count += 1

    perms := gen_permutation_string(qm_count)

    valid := 0

    for perm in perms {
        spring := replace_qms(r.springs, perm)
        if valid_spring(spring, r.sizes) do valid += 1
    }

    return valid
}

replace_qms :: proc(s: string, bin_str: string) -> string {
    l := len(s)
    ns := make([]u8, l)
    qmc := 0
    for c, i in s {
        if c == '?' {
            ns[i] = '.' if bin_str[qmc] == '0' else '#'
            qmc += 1
        }
        else do ns[i] = u8(c)
    }
    // assure the number of qms matched the number of binary digits
    fmt.assertf(qmc == len(bin_str), "Mismatch in question mark count %d != %d\n", qmc, len(bin_str))

    return string(ns)
}

gen_permutation_string :: proc(size: uint) -> []string {
    l := 1 << size
    w := size

    strs := make([]string, l)

    for i in 0..<l {
        // `*` is a dynamic width specifier
        strs[i] = fmt.tprintf("%*b", w, i)
    }

    return strs
}

valid_spring :: proc(s: string, expected_sizes: []int) -> bool {
    actual_sizes := make([dynamic]int)
    defer delete(actual_sizes)

    count := 0
    for c in s {
        switch c {
            case '.':
            if count > 0 {
                append(&actual_sizes, count)
                count = 0
            }
            case '#': count += 1
        }
    }
    if count > 0 do append(&actual_sizes, count)

    if len(actual_sizes) != len(expected_sizes) do return false
    for i in 0..<len(actual_sizes) {
        if actual_sizes[i] != expected_sizes[i] do return false
    }

    return true
}

@test
test_valid_spring :: proc(t : ^test.T) {
    test.expect(t, valid_spring("#", {1}) == true)
    test.expect(t, valid_spring(".#", {1}) == true)
    test.expect(t, valid_spring("#.#", {1, 1}) == true)
    test.expect(t, valid_spring("##.###", {2, 3}) == true)
    test.expect(t, valid_spring("##.###..#", {2, 3, 1}) == true)

    test.expect(t, valid_spring(".", {1}) == false)
    test.expect(t, valid_spring(".#", {2}) == false)
    test.expect(t, valid_spring("#.#", {2, 1}) == false)
    test.expect(t, valid_spring("##.###", {2, 2}) == false)
    test.expect(t, valid_spring("##.###..#", {2, 3, 0}) == false)
}
