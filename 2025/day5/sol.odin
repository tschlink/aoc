package day5

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

import "core:testing"

import "../lib"

Range :: [2]int

main :: proc() {

    lines := lib.read_lines("input.txt")

    ranges := make([dynamic]Range)

    range_idx := 0

    for line, idx in lines {
        if (line == "") do break
        str := strings.split(line, "-")
        n1, ok1 := strconv.parse_int(str[0])
        n2, ok2 := strconv.parse_int(str[1])
        if !ok1 || !ok2 do panic("Could not parse range number")

        append(&ranges, Range{n1, n2})
        range_idx = idx
    }

    total := 0
    for line in lines[range_idx+2:] {
        n, ok := strconv.parse_int(line)
        if !ok do panic("Failed to parse number")
        if is_in_range(n, ranges[:]) do total += 1
    }

    fmt.println("part 1 total:", total)

    fmt.println("rizan count", count_rizan(ranges[:]))

    consolidated := consolidate_ranges(ranges[:])

    count := len(ranges)
    con_count := len(consolidated)

    iter_count := 1
    for count != con_count {
        fmt.println("count:", count, "con_count:", con_count)
        iter_count += 1
        count = len(consolidated)
        consolidated = consolidate_ranges(consolidated)
        con_count = len(consolidated)
    }
    fmt.println(iter_count)

    slice.sort_by(consolidated, proc(a, b: Range) -> bool { return a.x < b.x })

    for i := 1; i < len(consolidated) - 2; i += 1 {
        prev := consolidated[i-1]
        curr := consolidated[i]
        next := consolidated[i+1]
        fmt.println(prev, curr, next)
        assert(curr.x > prev.y + 1)
        assert(curr.y < next.x - 1)
    }
    for r in consolidated do fmt.println(r)

    total_fresh_count := 0
    for range in consolidated {
        total_fresh_count += range.y - range.x + 1
    }
    fmt.println("total 2:", total_fresh_count)
}

is_in_range :: proc(num: int, ranges: []Range) -> bool {
    for range in ranges {
        if num >= range[0] && num <= range[1] do return true
    }
    return false
}

consolidate_ranges :: proc(ranges: []Range) -> []Range {
    consolidates := make([dynamic]Range)

    out: for range in ranges {
        for &con in consolidates {

            // con [1..5][11..20]
            // ran    [6..10]
            start_overlap := range.x >= con.x && range.x <= con.y + 1
            end_overlap   := range.y >= con.x - 1 && range.y <= con.y

            // current range is entirely inside an existing one
            if start_overlap && end_overlap {
                fmt.println(range, "is fully contained within", con)
                continue out
            }

            if start_overlap {
                // con: [5..15]
                // ran: [7..23]
                con.y = range.y
                continue out

            }

            if end_overlap {
                // con: [5..15]
                // ran: [2..14]
                con.x = range.x
                continue out
            }
        }

        // no overlap found, adding as a new range
        append(&consolidates, range)
    }

    return consolidates[:]
}

count_rizan :: proc(ranges: []Range) -> int {
    count := 0
    for r, i in ranges {
        count += r.y-r.x+1

        sum := 0
        for s, j in ranges[:i] {
            sum += intersect(s, r)
        }
        count -= sum
    }
    return count
}

intersect :: proc(s, r: Range) -> int {
    start := max(s.x, r.x)
    end   := min(s.y, r.y)
    if start <= end do return end - start + 1
    return 0
}

@test
intersect_test :: proc(t: ^testing.T) {
    testing.expect(t, intersect({1, 2},{3, 4}) == 0)
    testing.expect(t, intersect({1, 2},{2, 4}) == 1)
    testing.expect(t, intersect({1, 3},{2, 4}) == 2)
}
