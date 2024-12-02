package advent

import "core:fmt"
import "core:strings"
import "core:slice"
import "core:strconv"
import "aoc:txt"

main :: proc() {
    lines, str := txt.get_lines("input.txt")
    defer {
        delete(lines)
        delete(str)
    }

    left := make([]int, len(lines))
    right := make([]int, len(lines))

    for l, i in lines {
        nums := strings.split(l, "   ")
        assert(len(nums) == 2)
        n1, n2: int
        ok: bool
        n1, ok = strconv.parse_int(nums[0])
        n2, ok = strconv.parse_int(nums[1])
        left[i] = n1
        right[i] = n2
    }
    slice.sort(left)
    slice.sort(right)

    // part 1
    sum := 0
    for l, i in left do sum += abs(l - right[i])
    fmt.println(sum)

    // part 2
    sum = 0
    for l in left {
        count := 0
        for r in right {
            if l == r do count += 1
            if r > l do break
        }
        sum += l * count
    }
    fmt.println(sum)
}
