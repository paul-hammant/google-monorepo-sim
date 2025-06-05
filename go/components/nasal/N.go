package main

import "C" // Must import "C" to enable cgo.
import "fmt"

//export Java_components_nasal_N_N_1Init
func Java_components_nasal_N_N_1Init() {
	fmt.Print("<N>")
}

