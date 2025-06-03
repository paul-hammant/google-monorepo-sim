// Custom assert implementation for strictEqual for now - TODO use NPM version later
const assert = {
    strictEqual: (actual: any, expected: any, message?: string) => {
        if (actual !== expected) {
            throw new Error(message || `Assertion failed: Expected ${JSON.stringify(expected)}, but got ${JSON.stringify(actual)}`);
        }
    }
};

// Mock console.log to capture output
let capturedOutput = '';
const originalConsoleLog = console.log;
console.log = (...args: any[]) => {
    capturedOutput += args.join(' ') + '\n';
    // originalConsoleLog(...args); // Uncomment to see output during tests
};

// Import the component file and its function
import { printExclamation } from 'components/explanation/U0021';

// Call the function to trigger the console.log
printExclamation();

// Restore console.log after the function has executed
console.log = originalConsoleLog;

function runTests() {

    // Test 1: Check if the Explanation component printed "!"
    const expectedOutput = "!\n";

    assert.strictEqual(capturedOutput, expectedOutput, `Expected output to be "${expectedOutput.trim()}", but got "${capturedOutput.trim()}"`);

    // Reset captured output for potential future tests
    capturedOutput = '';
}

runTests();
