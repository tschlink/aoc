package day2

import "core:fmt"
import "core:strings"
import "core:strconv"

import "../../aoc"

R :: 12
G :: 13
B :: 14

main :: proc() {
    part1()
    part2()
}

part1 :: proc() {
    lines := aoc.file2lines("input.txt")

    sum := 0
    for line, idx in lines {
        s1 := strings.split(line, ": ")

        sets := strings.split(s1[1], "; ")
        possible := true
        for set in sets {
            cubes := strings.split(set, ", ")
            for cube in cubes {
                info := strings.split(cube, " ")
                assert(len(info) == 2)
                num, ok := strconv.parse_i64(info[0])
                if !ok do fmt.panicf("Line %v: %v is not a number", s1[0], info[0])
                switch info[1] {
                    case "red":
                    if num > R do possible = false
                    case "green":
                    if num > G do possible = false
                    case "blue":
                    if num > B do possible = false
                    case: fmt.panicf("Line %v: %v not a valid cube color.", s1[0], info[1])
                }
            }
            if !possible do continue // not a perfect optimization I know
        }
        if possible do sum += idx + 1
    }
    fmt.println(sum)
}
part2 :: proc() {
    lines := aoc.file2lines("input.txt")

    sum := 0
    for line, idx in lines {
        s1 := strings.split(line, ": ")
        sets := strings.split(s1[1], "; ")

        mr, mg, mb: int

        for set in sets {
            cubes := strings.split(set, ", ")
            for cube in cubes {
                info := strings.split(cube, " ")
                assert(len(info) == 2)
                num, ok := strconv.parse_int(info[0])
                if !ok do fmt.panicf("Line %v: %v is not a number", s1[0], info[0])
                switch info[1] {
                    case "red":
                    if mr < num do mr = num
                    case "green":
                    if mg < num do mg = num
                    case "blue":
                    if mb < num do mb = num
                    case: fmt.panicf("Line %v: %v not a valid cube color.", s1[0], info[1])
                }
            }
        }
        sum += mr * mg * mb
    }
    fmt.println(sum)
}
