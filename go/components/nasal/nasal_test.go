package main

import (
	"bytes"
	"os"
	"testing"
)

func TestMInit(t *testing.T) {
	// Capture the output
	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	var buf bytes.Buffer
	done := make(chan struct{})

	go func() {
		buf.ReadFrom(r)
		r.Close()
		close(done)
	}()

	// Call the native init function
	Java_components_nasal_M_M_1Init()

	// Restore stdout and close the writer
	w.Close()
	os.Stdout = oldStdout
	<-done // wait for goroutine to finish

	// Check the output
	expected := "<M>"
	if buf.String() != expected {
		t.Errorf("expected %s, got %s", expected, buf.String())
	}
}

func TestNInit(t *testing.T) {
	// Capture the output
	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	var buf bytes.Buffer
	done := make(chan struct{})

	go func() {
		buf.ReadFrom(r)
		r.Close()
		close(done)
	}()

	// Call the native init function
	Java_components_nasal_N_N_1Init()

	// Restore stdout and close the writer
	w.Close()
	os.Stdout = oldStdout
	<-done // wait for goroutine to finish

	// Check the output
	expected := "<N>"
	if buf.String() != expected {
		t.Errorf("expected %s, got %s", expected, buf.String())
	}
}
