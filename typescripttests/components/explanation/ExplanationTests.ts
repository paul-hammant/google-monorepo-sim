import { describe, it, beforeEach, afterEach } from 'mocha';
import * as assert from 'assert';
import { printExclamation } from 'components/explanation/U0021';

describe('Explanation component', () => {
    let capturedOutput = '';
    const originalConsoleLog = console.log;

    beforeEach(() => {
        capturedOutput = '';
        console.log = (...args: any[]) => {
            capturedOutput += args.join(' ') + '\n';
        };
    });

    afterEach(() => {
        console.log = originalConsoleLog;
    });

    it('should print an exclamation mark', () => {
        // Call the function to trigger the console.log
        printExclamation();

        // Test the output
        const expectedOutput = "!\n";
        assert.strictEqual(capturedOutput, expectedOutput, `Expected output to be "${expectedOutput.trim()}", but got "${capturedOutput.trim()}"`);
    });
});
