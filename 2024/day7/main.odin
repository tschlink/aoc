package advent

import "aoc:txt"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

main :: proc() {
    lines, str := txt.get_lines("input.txt")
    defer {
        delete(lines)
        delete(str)
    }

    sum := 0
    out: for l in lines {
        s := strings.split(l, ": ")
        result, rok := strconv.parse_int(s[0])
        if !rok do fmt.panicf("Failed to parse number", s[0])
        nums, ok := txt.split_nums(s[1], " ")
        if !ok do fmt.panicf("Failed to parse numbers in", s[1])
        //fmt.println(result, nums)

        n_op := 3
        n_slots := len(nums) - 1
        nops := cast(int)math.pow(f64(n_op), f64(n_slots))
        ops := make([]int, n_slots)
        for i in 0..<nops {
            //fmt.println(ops)
            res := nums[0]
            for j in 0..<n_slots{
                next_num := nums[j + 1]
                switch ops[j] {
                    case 0: res += next_num
                    case 1: res *= next_num
                    case 2: 
                        cnt := 0
                        tmp := next_num
                        for tmp != 0 {
                            cnt += 1
                            tmp /= 10
                        }
                        res *= auto_cast math.pow(10, f64(cnt))
                        res += next_num
                    case: panic("Unknown operation")
                }
            }
            if result == res {
                //fmt.println("Success!", result, ":", nums, ops)
                sum += res
                continue out
            }
            inc(ops, n_op)
        }
    }
    fmt.println(sum)
}

inc :: proc(ops: []int, nops: int) {
    for i := len(ops) - 1; i >= 0; i -= 1 {
        n :=  ops[i] + 1
        if n / nops == 1 {
            // carry
            ops[i] = 0
        } else {
            // inc
            ops[i] = n
            break
        }
    }
}
