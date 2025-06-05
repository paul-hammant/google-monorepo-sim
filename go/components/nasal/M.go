package main

import "C" // Must import "C" to enable cgo.
import "fmt"

//export Java_components_nasal_M_M_1Init
func Java_components_nasal_M_M_1Init() {
	fmt.Print("<M>")
}

func main() {} // Required for c-shared library

