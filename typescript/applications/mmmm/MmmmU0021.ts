import { printExclamation } from 'typescript/components/explanation/U0021';

declare const require: (path: string) => any;
declare const process: { cwd: () => string };

export function main() {
    // Absolute paths are required for FFI loading (see CLAUDE.md), but must
    // not be machine-hardcoded — aeb runs the test from the repo root, so
    // anchor on process.cwd() and survive the repo being relocated.
    const root = process.cwd();
    const ffi = require(root + '/libs/javascript/npm_vendored/node_modules/ffi-napi-v22/lib/ffi.js');
    const libPath = root + '/target/build/go/components/nasal/lib/libgonasal.so';
    const lib = ffi.Library(libPath, {
        'Java_components_nasal_M_M_1Init': ['void', []]
    });

    lib.Java_components_nasal_M_M_1Init();
    lib.Java_components_nasal_M_M_1Init();
    lib.Java_components_nasal_M_M_1Init();
    lib.Java_components_nasal_M_M_1Init();
    
    console.log('Mmmm');

    printExclamation();
}

main();
