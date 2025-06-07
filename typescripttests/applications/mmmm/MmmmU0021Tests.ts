import * as assert from 'assert';
// Mock console.log to capture output
let capturedOutput = '';
const originalConsoleLog = console.log;
console.log = (...args: any[]) => {
    capturedOutput += args.join(' ') + '\n';
    // originalConsoleLog(...args); // Uncomment to see output during tests
};

// Import the main application file (for side effects and execution)
// This will trigger the Go native calls and the Explanation component's console.log
import 'applications/mmmm/MmmmU0021';

// Restore console.log after the import has executed its side effects
console.log = originalConsoleLog;

function runTests() {

    // Test 1: Check if the Go native calls printed "<M>" four times
    // And if the Explanation component printed "!"
    const expectedOutput = "Mmmm\n!\n"; // Assuming each print adds a newline

    assert.strictEqual(capturedOutput, expectedOutput, `Expected output to be "${expectedOutput.trim()}", but got "${capturedOutput.trim()}"`);

    // Reset captured output for potential future tests
    capturedOutput = '';

    console.log("tests passed")
}

runTests();
