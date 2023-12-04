    package main

    import "core:fmt"
    import "core:os"
    import "core:strconv"
    import "core:strings"

    input_file :: "input.txt"

    Position :: distinct [2]int

    file2lines :: proc(filename: string) -> []string {
        buf, ok := os.read_entire_file(input_file)
        if !ok {
            fmt.println("Failed to read input file")
            os.exit(1)
        }
        str := strings.clone_from_bytes(buf)
        return strings.split(str, "\n")

    }
    main :: proc() {
        lines := file2lines(input_file)
        pos: Position
        for l in lines {
            if len(l) == 0 { break }
            instr := strings.split(l, " ")
            fmt.println(instr)
            val, _ := strconv.parse_int(instr[1])
        switch instr[0] {
            case "forward":
                pos.x += val
            case "up":
                pos.y -= val
            case "down":
                pos.y += val
        }
    }
    fmt.println(pos.x * pos.y)
}
