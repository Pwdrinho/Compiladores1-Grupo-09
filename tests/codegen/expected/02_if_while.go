package main

import "fmt"

func main() {
    var x int = 0
    for (x < 3) {
        x = (x + 1)
    }
    if (x == 3) {
        fmt.Println(x)
        return
    } else {
        fmt.Println(0)
        return
    }
}

