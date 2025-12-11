package day11

import "core:fmt"
import "core:strings"
import "core:slice"

import "core:testing"

import "../lib"

// Node in a directed graph
Node :: struct {
    name: string,
    children_names: []string,
    children: []^Node,
}

main :: proc() {
    lines := lib.read_lines("input.txt")
    defer delete(lines)

    node_mapping := make(map[string]^Node)
    nodes := make([dynamic]^Node)

    defer {
        delete_map(node_mapping)
        delete(nodes)
    }

    for line in lines {
        s := strings.split(line, " ")
        assert(s[0][len(s[0])-1] == ':')

        node := new(Node)
        node.name = s[0][:len(s[0])-1]

        node.children_names = slice.clone(s[1:len(s)])
        node.children = make([]^Node, len(node.children_names))

        node_mapping[node.name] = node
        append(&nodes, node)
    }

    out := new(Node)
    out.name = "out"
    node_mapping["out"] = out

    for node in nodes {
        for name, i in node.children_names {
            node.children[i] = node_mapping[name]
        }
    }


    you, ok := node_mapping["you"]
    if ok {
        counter := 0
        // fuck around and...
        find_out(you, &counter)

        fmt.println("Number of paths:", counter)
    }

    // part2
    assert("svr" in node_mapping)
    svr := node_mapping["svr"]

    //total_path_count := 0
    //count_paths(svr, "out", &total_path_count)
    //fmt.println("total path counts from svr to out:", total_path_count)

    valid_path_count := 0
    path := make([dynamic]^Node)
    dsf(node_mapping["svr"], "out", &path, false, false, &valid_path_count)
    fmt.println("Valid paths:", valid_path_count)
}

find_out :: proc(n: ^Node, counter: ^int) {
    count_paths(n, "out", counter)
}

count_paths :: proc(src: ^Node, dest: string, counter: ^int) {
    for c in src.children {
        find_out(c, counter)
    }
    if src.name == dest {
        assert(src.children == nil)
        counter^ += 1
    }
}

dsf :: proc(src: ^Node, dest: string, path: ^[dynamic]^Node, dac, fft: bool, counter: ^int) {
    for n in path do if n.name == src.name do panic("Cycle found!")
    append(path, src)
    dac := dac || src.name == "dac"
    fft := fft || src.name == "fft"
    if src.name == dest && dac && fft {
        if counter^ % 1000 == 0 do fmt.println(counter^)
        counter^ += 1
    }
    else {
        for c in src.children {
            dsf(c, dest, path, dac, fft, counter)
        }
    }
    unordered_remove(path, len(path)-1)
}

