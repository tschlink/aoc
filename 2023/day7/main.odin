package day7

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"


Hand_Type :: enum {
    FIVE_KIND = 0,
    FOUR_KIND,
    FULL_HOUSE,
    THREE_KIND,
    TWO_PAIR,
    PAIR,
    HIGH_CARD
}

Hand :: struct {
    cards: string,
    bid: int,
    type: Hand_Type,

}

main :: proc() {
    part1()
    part2()
}

part1 :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    hands := make([]Hand, len(lines) - 1)

    for line, idx in lines {
        if line == "" do continue
        info := strings.split(line, " ")
        assert(len(info) == 2)

        hand := get_hand_p1(info[0])
        bid, ok := strconv.parse_int(info[1])
        if !ok do panic("Could not parse bid")

        hands[idx] = {info[0], bid, hand}
    }

    slice.sort_by(hands, sort_ranking_proc_p1)

    res := 0
    for hand, idx in hands {
        res += (idx+1) * hand.bid
    }
    fmt.println(res)
}

part2 :: proc() {
    content, input_ok := os.read_entire_file("input.txt")
    if !input_ok do panic("Could not read input file")
    defer delete(content)

    lines := strings.split_lines(string(content))
    defer delete(lines)

    hands := make([]Hand, len(lines) - 1)

    for line, idx in lines {
        if line == "" do continue
        info := strings.split(line, " ")
        assert(len(info) == 2)

        hand := get_hand_p2(info[0])
        bid, ok := strconv.parse_int(info[1])
        if !ok do panic("Could not parse bid")

        hands[idx] = {info[0], bid, hand}
    }

    slice.sort_by(hands, sort_ranking_proc_p2)

    res := 0
    for hand, idx in hands {
        fmt.println(hand)
        res += (idx+1) * hand.bid
    }
    fmt.println(res)
}

// return -1 or 1 depending on ranking of h1 compared to h2
sort_ranking_proc_p1 :: proc(h1, h2: Hand) -> bool {
    comp := h1.type - h2.type
    if int(comp) > 0 do return true
    if int(comp) < 0 do return false

    res := compare_highest_card_p1(h1, h2)
    if res == -1 do return true
    else if res == 1 do return false
    else panic("Found identical hands")
}

compare_highest_card_p1 :: proc(h1, h2: Hand) -> int {
    all_cards := map[u8]int{
        'A' = 0,
        'K' = 1,
        'Q' = 2,
        'J' = 3,
        'T' = 4,
        '9' = 5,
        '8' = 6,
        '7' = 7,
        '6' = 8,
        '5' = 9,
        '4' = 10,
        '3' = 11,
        '2' = 12,
    }
    h1r := make([]int, 5)
    h2r := make([]int, 5)

    for idx in 0..<5 {
        h1r[idx] = all_cards[h1.cards[idx]]
        h2r[idx] = all_cards[h2.cards[idx]]
    }

    for i in 0..<5 {
        comp := h1r[i] - h2r[i]
        if comp < 0 do return 1
        else if comp > 0 do return -1
    }

    fmt.panicf("Found identical hands!", h1, h2)
}

// return -1 or 1 depending on ranking of h1 compared to h2
sort_ranking_proc_p2 :: proc(h1, h2: Hand) -> bool {
    comp := h1.type - h2.type
    if int(comp) > 0 do return true
    if int(comp) < 0 do return false

    res := compare_highest_card_p2(h1, h2)
    if res == -1 do return true
    else if res == 1 do return false
    else panic("Found identical hands")
}

compare_highest_card_p2 :: proc(h1, h2: Hand) -> int {
    all_cards := map[u8]int{
        'A' = 0,
        'K' = 1,
        'Q' = 2,
        'T' = 3,
        '9' = 4,
        '8' = 5,
        '7' = 6,
        '6' = 7,
        '5' = 8,
        '4' = 9,
        '3' = 10,
        '2' = 11,
        'J' = 12,
    }

    h1r := make([]int, 5)
    h2r := make([]int, 5)

    for idx in 0..<5 {
        h1r[idx] = all_cards[h1.cards[idx]]
        h2r[idx] = all_cards[h2.cards[idx]]
    }

    for i in 0..<5 {
        comp := h1r[i] - h2r[i]
        if comp < 0 do return 1
        else if comp > 0 do return -1
    }

    fmt.panicf("Found identical hands!", h1, h2)
}

get_hand_p1 :: proc(cards: string) -> Hand_Type {
    counts := count_cards(cards)

    triple := false
    pair   := false
    double_pair := false

    for k, v in counts {
        if v == 5 do return .FIVE_KIND
        if v == 4 do return .FOUR_KIND
        if v == 3 do triple = true
        if v == 2 {
            if pair  do double_pair = true
            if !pair do pair = true
        }
    }

    if triple && pair do return .FULL_HOUSE
    if triple do return .THREE_KIND
    if double_pair do return .TWO_PAIR
    if pair do return .PAIR
    return .HIGH_CARD
}

get_hand_p2 :: proc(cards: string) -> Hand_Type {
    // Very cringe solution. I'm sure there's a more elegant way of doing this
    counts := count_cards(cards)

    joker_count, ok := counts['J']
    if !ok do return get_hand_p1(cards)

    triple := false
    pair   := false
    double_pair := false

    for k, v in counts {
        if v == 5 do return .FIVE_KIND
        if v == 4 do return .FIVE_KIND // JJJJX or XXXXJ are always Five of a kind
        if v == 3 {
            if k != 'J' {
                if joker_count == 2 do return .FIVE_KIND
                if joker_count == 1 do return .FOUR_KIND
            } else {
                return .FOUR_KIND
            }
            triple = true
        }
        if v == 2 {
            if k != 'J' {
                if joker_count == 3 do return .FIVE_KIND
                if joker_count == 2 do return .FOUR_KIND
            } else {
            }
            if pair  do double_pair = true
            if !pair do pair = true
        }
    }

    // pretty sure some of these are never used in p2
    if triple && pair do return .FULL_HOUSE
    if triple do return .THREE_KIND
    if double_pair && joker_count == 1 do return .FULL_HOUSE
    if double_pair do return .TWO_PAIR
    if pair && joker_count == 2 do return .THREE_KIND
    if pair && joker_count == 1 do return .THREE_KIND
    return .PAIR
}

count_cards :: proc(cards: string) -> map[rune]int {
    counts := make(map[rune]int)

    for card, idx in cards {
        if card in counts do continue // no point in counting the same type twice
        occurrences := 1
        for c, cidx in cards {
            if idx == cidx do continue // don't count itself twice
            if card == c do occurrences += 1
        }
        counts[card] = occurrences
    }
    return counts
}
