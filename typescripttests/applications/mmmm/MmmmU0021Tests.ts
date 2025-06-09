import { describe, it, beforeEach, afterEach } from 'mocha';
import * as assert from 'assert';
import {main} from 'applications/mmmm/MmmmU0021';

describe('MmmmU0021 application', () => {
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

    it('should print "Mmmm" and "!"', () => {
        main();

        // Test the output
        const expectedOutput = "Mmmm\n!\n";
        assert.strictEqual(capturedOutput, expectedOutput, `Expected output to be "${expectedOutput.trim()}", but got "${capturedOutput.trim()}"`);
    });
});
