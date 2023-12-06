package day5

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

Range :: struct {
    dest: int,
    src: int,
    len: int,
}

Table :: []Range

maps := [?]string {
    "seed-to-soil map:",
    "soil-to-fertilizer map:",
    "fertilizer-to-water map:",
    "water-to-light map:",
    "light-to-temperature map:",
    "temperature-to-humidity map:",
    "humidity-to-location map:",
}

main :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    // parse seeds
    seed_numbers := strings.split(lines[0], " ")
    assert(seed_numbers[0] == "seeds:")

    seeds, seeds_ok := parse_int_slice(seed_numbers[1:])
    if !seeds_ok do panic("Failed to parse seed list")

    fmt.println(seeds)

    current_map_idx := 0
    in_map := false
    tbl_start_idx := 0
    tables := make([]Table, len(maps))

    for line, idx in lines[2:] {
        assert(current_map_idx < len(maps))

        // start of new map
        if !in_map && line == maps[current_map_idx] {
            in_map = true
            tbl_start_idx = idx + 1
        }

        // parse each line and add to current map
        if in_map && line != "" {
            continue
        }

        if in_map && line == "" {
            in_map = false
            fmt.printf("Found table %s in lines %d to %d\n", maps[current_map_idx], tbl_start_idx + 3, idx + 2)
            tables[current_map_idx] = parse_table(lines[tbl_start_idx + 2 : idx + 2])
            current_map_idx += 1
        }
    }

    lowest_loc := max(int)
    // part 1
    for seed in seeds {
        n := seed
        for tbl in tables {
            //fmt.print(n, " ")
            n = lookup(n, tbl)
        }
        //fmt.print(n, "\n")
        if n < lowest_loc do lowest_loc = n
    }

    fmt.println(lowest_loc)

    lowest_loc = max(int)

    // part2
    // this is incredibly slow, find a way to speed up
    for i := 0; i < len(seeds) - 2; i += 2 {
        fmt.println("Checking range", seeds[i], "to", seeds[i]+seeds[i+1])
        for seed in seeds[i]..=seeds[i]+seeds[i+1] {
            n := seed
            for tbl in tables {
                //fmt.print(n, " ")
                n = lookup(n, tbl)
            }
            //fmt.print(n, "\n")
            if n < lowest_loc do lowest_loc = n
        }
    }
    fmt.println(lowest_loc)
}

lookup :: proc(number: int, tbl: Table) -> int {
    for range in tbl {
        if number >= range.src && number < range.src + range.len {
            return range.dest + (number - range.src)
        }
    }
    return number
}

parse_int_slice :: proc(str: []string, alloc := context.allocator) -> (out: []int, ok: bool) {
    out = make([]int, len(str), alloc)
    for s, idx in str {
        num := strconv.parse_int(s) or_return
        out[idx] = num
    }
    ok = true
    return
}

parse_table :: proc(lines: []string) -> Table {
    tbl := make([]Range, len(lines))

    for line, idx in lines {
        numbers := strings.split(line, " ")
        res, ok := parse_int_slice(numbers)
        if !ok do panic("Failed to parse table data")

        tbl[idx] = {res[0], res[1], res[2]}
    }

    return tbl
}
