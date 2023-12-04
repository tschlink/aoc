package day4

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
    part1()
    part2()
}

part1 :: proc() {
    input, ok := os.read_entire_file("input.txt")
    if !ok do panic("Failed to read input file")
    defer delete(input)

    lines := strings.split_lines(string(input))
    defer delete(lines)

    points := 0

    for line in lines {
        if line == "" do continue

        card := strings.split(line, ": ")
        assert(len(card) == 2)

        numbers := strings.split(card[1], " | ")
        assert(len(numbers) == 2)

        winning_numbers_str := strings.split(numbers[0], " ")
        elf_numbers_str     := strings.split(numbers[1], " ")


        winning_numbers := make([dynamic]int)
        elf_numbers     := make([dynamic]int)

        for num in winning_numbers_str {
            if num == "" do continue

            n, _ := strconv.parse_int(num)
            append(&winning_numbers, n)
        }
        for num in elf_numbers_str {
            if num == "" do continue

            n, _ := strconv.parse_int(num)
            append(&elf_numbers, n)
        }

        // could sort numbers to do optimization, but not worth it

        card_points := 0
        for i in winning_numbers {
            for j in elf_numbers {
                if i == j {
                    if card_points == 0 do card_points = 1
                    else do card_points *= 2
                }
            }
        }
        points += card_points

    }
    fmt.println(points)

}

Card :: struct {
    winning_numbers: []int,
    elf_numbers    : []int,
    points: int,
}

part2 :: proc() {
    input, ok := os.read_entire_file("input.txt")
    if !ok do panic("Failed to read input file")
    defer delete(input)

    lines := strings.split_lines(string(input))
    defer delete(lines)

    total := 0

    cards := make([]Card, len(lines))

    for line, idx in lines {
        line := strings.trim(line, " ")
        if line == "" do continue

        card := strings.split(line, ": ")
        assert(len(card) == 2)

        numbers := strings.split(card[1], " | ")
        assert(len(numbers) == 2)

        winning_numbers_str := strings.split(numbers[0], " ")
        elf_numbers_str     := strings.split(numbers[1], " ")

        winning_numbers := make([dynamic]int)
        elf_numbers     := make([dynamic]int)

        for num in winning_numbers_str {
            if num == "" do continue

            n, _ := strconv.parse_int(num)
            append(&winning_numbers, n)
        }
        for num in elf_numbers_str {
            if num == "" do continue

            n, _ := strconv.parse_int(num)
            append(&elf_numbers, n)
        }

        cards[idx] = {winning_numbers[:], elf_numbers[:], -1}
    }

    for card, idx in &cards {
        if card.points == -1 {
            card.points = card_count(idx, cards)
        }
        total += card.points
    }

    fmt.println(total)
}

card_count :: proc(idx: int, cards: []Card, lvl := 0) -> int {
    total := 0
    card_points := 0

    for i in cards[idx].winning_numbers {
        for j in cards[idx].elf_numbers {
            if i == j {
                card_points += 1
            }
        }
    }
    indent := strings.repeat("\t", lvl)

    for i in 0..<card_points {
        total += card_count(idx + i + 1, cards, lvl + 1)
    }

    total += 1 // count itself

    return total
}
