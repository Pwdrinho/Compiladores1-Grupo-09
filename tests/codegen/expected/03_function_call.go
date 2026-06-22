package main

import "fmt"

func soma(a int, b int) int {
    return (a + b)
}

func main() {
    var r int = soma(2, 3)
    fmt.Println(r)
    return
}

