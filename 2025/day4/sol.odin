package day4

import "core:fmt"
import "core:strings"

import "../lib"

main1 :: proc() {

    lines := lib.read_lines("input.txt")
    h := len(lines)
    w := len(lines[0])

    // lines; y
    mat := make([][]u8, h)

    // columns, x
    for &i in mat do i = make([]u8, w)

    for line, y in lines {
        for r, x in line {
            if r == '@' {
                if y > 0 && x > 0   do mat[y-1][x-1] += 1 // top left
                if          x > 0   do mat[y  ][x-1] += 1 // left
                if          x < w-1 do mat[y  ][x+1] += 1 // right
                if y > 0 && x < w-1 do mat[y-1][x+1] += 1 // top right

                if y < h-1 && x > 0   do mat[y+1][x-1] += 1 // bottom left
                if y > 0              do mat[y-1][x  ] += 1 // top
                if y < h-1            do mat[y+1][x  ] += 1 // bottom
                if y < h-1 && x < w-1 do mat[y+1][x+1] += 1 // bottom right
            }
        }
    }

    sum := 0
    for line, y in lines {
        for r, x in line {
            if r == '@' && mat[y][x] < 4 do sum += 1
        }
    }
    fmt.println("sum:", sum)
}

main :: proc() {

    contents := lib.read_lines("input.txt")

    lines := make([][]u8, len(contents))
    for line, i in contents do lines[i] = transmute([]u8)line

    h := len(lines)
    w := len(lines[0])

    // lines; y
    mat := make([][]u8, h)

    // columns, x
    for &i in mat do i = make([]u8, w)

    zero :: proc(mat: [][]u8) {
        for row, y in mat {
            for _, x in row {
                mat[y][x] = 0
            }
        }
    }

    sum := 0
    rolls_removed := true

    for rolls_removed {
        rolls_removed = false

        zero(mat)

        for line, y in lines {
            for r, x in line {
                if r == '@' {
                    if y > 0 && x > 0   do mat[y-1][x-1] += 1 // top left
                    if          x > 0   do mat[y  ][x-1] += 1 // left
                    if          x < w-1 do mat[y  ][x+1] += 1 // right
                    if y > 0 && x < w-1 do mat[y-1][x+1] += 1 // top right

                    if y < h-1 && x > 0   do mat[y+1][x-1] += 1 // bottom left
                    if y > 0              do mat[y-1][x  ] += 1 // top
                    if y < h-1            do mat[y+1][x  ] += 1 // bottom
                    if y < h-1 && x < w-1 do mat[y+1][x+1] += 1 // bottom right
                }
            }
        }

        for line, y in lines {
            for r, x in line {
                if r == '@' && mat[y][x] < 4 {
                    rolls_removed = true
                    lines[y][x] = 'x'
                    sum += 1
                }
            }
        }
    }
    fmt.println("sum:", sum)
}
