package day6

import "core:fmt"

Race :: struct {
    time: int,
    distance: int,
}
example_races_p1 := [?]Race {
    {7, 9},
    {15, 40},
    {30, 200},
}

input_races_p1 := [?]Race {
    {52, 426},
    {94, 1374},
    {75, 1279},
    {94, 1216},
}

example_race_p2 := [?]Race {
    {71530, 940200},
}

input_race_p2 := [?]Race {
    {52947594, 426137412791216},
}
main :: proc() {
    res := 1
    for race, idx in input_race_p2 {
        winning_config := 0
        for speed in 0..=race.time {
            distance := (race.time - speed) * speed
            if distance > race.distance {
                //fmt.printf("Race %d: Holding button %d seconds wins with %d distance\n", idx+1, speed, distance)
                winning_config += 1
            }
        }
        res *= winning_config
    }

    fmt.println(res)
}
