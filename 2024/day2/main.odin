package advent

import "aoc:txt"
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:strconv"

main :: proc() {
    lines, str := txt.get_lines("input.txt")
    defer {
        delete(lines)
        delete(str)
    }

    safe := 0

    // part 1
    for l in lines {
        n, ok := txt.split_nums(l, " ")
        if !ok do panic("Failed parsing numbers")

        inc := true if n[0] < n[1] else false
        succ := true
        for i := 0; i < len(n) - 1; i += 1 {
            dif := abs(n[i] - n[i+1])
            if (n[i] < n[i + 1]) != inc || dif < 1 || dif > 3 do succ = false
        }
        if succ do safe += 1
    }
    fmt.println(safe)

    // part 2
    safe = 0

    for l in lines {
        m, ok := txt.split_nums(l, " ")
        if !ok do panic("Failed parsing numbers")

        success := false
        for i in 0..<len(m) {
            n := slice.to_dynamic(m)
            defer delete(n)
            ordered_remove(&n, i)

            succ := true
            inc := true if n[0] < n[1] else false
            for i := 0; i < len(n) - 1; i += 1 {
                dif := abs(n[i] - n[i+1])
                if (n[i] < n[i + 1]) != inc || dif < 1 || dif > 3 do succ = false
            }
            fmt.println(m, n, "GOOD" if succ else "BAD")
            if succ {
                success = true
                break
            }
        }
        if success do safe += 1
    }
    fmt.println(safe)
}
