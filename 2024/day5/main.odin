package advent

import "aoc:txt"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"

main :: proc() {
    lines, str := txt.get_lines("input.txt")
    defer {
        delete(lines)
        delete(str)
    }

    orderings := make([dynamic][2]int)
    updates := make([dynamic][]int)
    defer delete(orderings)
    defer delete(updates)
    start_updates := false
    for l in lines {
        if l == "" {
            start_updates = true
            continue
        }

        if !start_updates {
            nums, ok := txt.split_nums(l, "|")
            if !ok do fmt.panicf("Failed to parse numbers in %v\n", l)
            assert(len(nums) == 2)
            append(&orderings, [2]int{nums[0], nums[1]})
            delete(nums)
        } else {
            nums, ok := txt.split_nums(l, ",")
            if !ok do fmt.panicf("Failed to parse a number in %s\n", l)
            append(&updates, nums)
        }
    }

    // part 1
    bad_updates := make([dynamic][]int)
    defer delete(bad_updates)
    good_order := 0
    out: for u in updates {
        for n, i in u[:len(u)-1] {
            for m in u[i+1:] {
                if !contains(orderings[:], n, m) {
                    append(&bad_updates, u)
                    continue out
                }
            }
        }
        good_order += u[len(u) / 2]
    }
    fmt.println(good_order)

    // part 2
    sum := 0
    for u in bad_updates {
        sum += sort(orderings[:], u)
    }
    fmt.println(sum)
}

contains :: proc(orderings: [][2]int, a, b: int) -> bool {
    for o in orderings {
        if o == {a, b} do return true
        if o == {b, a} do return false
    }
    return true
}

sort :: proc(orderings: [][2]int, update: []int) -> int {
    for i := 0; i < len(update) - 1; i += 1 {
        for j := i + 1; j < len(update); j += 1 {
            for o in orderings {
                if o == {update[j], update[i]} {
                    slice.swap(update, i, j)
                    break
                }
            }
        }
    }
    return update[len(update)/2]
}
