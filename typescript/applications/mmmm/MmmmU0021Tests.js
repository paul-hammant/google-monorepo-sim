"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var assert = require("assert");
// Mock console.log to capture output
var capturedOutput = '';
var originalConsoleLog = console.log;
console.log = function () {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    capturedOutput += args.join(' ') + '\n';
    // originalConsoleLog(...args); // Uncomment to see output during tests
};
// Import the main application file (for side effects and execution)
// This will trigger the Go native calls and the Explanation component's console.log
require("applications/mmmm/MmmmU0021");
// Restore console.log after the import has executed its side effects
console.log = originalConsoleLog;
function runTests() {
    // Test 1: Check if the Go native calls printed "<M>" four times
    // And if the Explanation component printed "!"
    var expectedOutput = "Mmmm\n!\n"; // Assuming each print adds a newline
    assert.strictEqual(capturedOutput, expectedOutput, "Expected output to be \"".concat(expectedOutput.trim(), "\", but got \"").concat(capturedOutput.trim(), "\""));
    // Reset captured output for potential future tests
    capturedOutput = '';
}
runTests();
