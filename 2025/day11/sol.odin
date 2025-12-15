package day11

import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"

import "core:testing"

import "../lib"

// Node in a directed graph
Node :: struct {
    name: string,
    children: [dynamic]^Node,

    // part2
    reachable_paths: int,
}

make_node :: proc(name: string) -> ^Node {
    n := new(Node)
    n.name = name
    n.reachable_paths = 1
    return n
}

main :: proc() {
    lines := lib.read_lines("input.txt")
    defer delete(lines)

    node_mapping := make(map[string]^Node)

    defer delete_map(node_mapping)

    for line in lines {
        s := strings.split(line, " ")
        assert(s[0][len(s[0])-1] == ':')

        name := s[0][:len(s[0])-1]
        n, ok := node_mapping[name]

        if !ok {
            n = make_node(name)
            node_mapping[name] = n
        }

        children_names := s[1:]
        n.children = make([dynamic]^Node, len(children_names))

        for child_name, i in children_names {
            assert(len(child_name) == 3)
            c, cok := node_mapping[child_name]
            if !cok {
                c = make_node(child_name)
                node_mapping[child_name] = c
            }
            n.children[i] = c
        }
    }

    // part 1
    you, ok := node_mapping["you"]
    if ok {
        counter := 0
        // fuck around and...
        find_out(you, &counter)
        fmt.println("Number of paths:", counter)
    }


    /*{
        // graphviz file
        sb := strings.builder_make()

        strings.write_string(&sb, "digraph {\n")
        for k, v in node_mapping {
            strings.write_string(&sb, "  ")
            strings.write_string(&sb, k)
            strings.write_string(&sb, " -> {")

            for c, i in v.children {
                assert(len(c.name) == 3)
                if k == "out" do continue
                strings.write_string(&sb, c.name)
                if i != len(v.children) - 1 do strings.write_string(&sb, " ")
            }
            strings.write_string(&sb, "}\n")
        }
        strings.write_string(&sb, "}\n")

        buf := strings.to_string(sb)
        os.write_entire_file("out.dot", transmute([]u8)buf)
    }*/

    {
        // part2
        //assert("svr" in node_mapping)
        svr := node_mapping["svr"]
        fmt.println(svr)

        counter := 0
        //count_paths(node_mapping["svr"], "fft", &counter)
        fmt.println("svr -> fft:", counter)
    }
}

collapse_graph :: proc(map[string]^Node) {}

find_out :: proc(n: ^Node, counter: ^int) {
    count_paths(n, "out", counter)
}

count_paths :: proc(src: ^Node, dest: string, counter: ^int) {
    for c in src.children {
        count_paths(c, dest, counter)
    }
    if src.name == dest {
        counter^ += 1
    }
}

dsf :: proc(src: ^Node, dest: string, path: ^[dynamic]^Node, dac, fft: bool, counter: ^int) {
    append(path, src)
    dac := dac || src.name == "dac"
    fft := fft || src.name == "fft"
    if src.name == dest && dac && fft {
        counter^ += 1
    }
    else {
        for c in src.children {
            dsf(c, dest, path, dac, fft, counter)
        }
    }
    unordered_remove(path, len(path)-1)
}

bfs :: proc(src: ^Node, dest: string) -> int {
    c1 := make([dynamic]^Node)
    c2 := make([dynamic]^Node)

    reached := make(map[string]int)

    append(&c1, src)
    count := 0

    for true {
        for n in c1 {
            r, ok := reached[n.name]
            if !ok {
                reached[n.name] = 1
            }
            else {
                reached[n.name] += 1
                continue // skip what we already touched
            }

            if n.name != dest {
                append_elems(&c2, ..n.children[:])
            } else {
                count += 1
            }
        }
        clear(&c1)
        c1, c2 = c2, c1
        fmt.println("Frontier length", len(c1))
        if len(c1) == 0 do break
    }
    return count
}
