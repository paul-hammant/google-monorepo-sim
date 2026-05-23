import { printExclamation } from 'typescript/components/explanation/U0021';

declare const require: (path: string) => any;

export function main() {
    const ffi = require('/home/paul/scm/AetherThings/google-monorepo-sim/libs/javascript/npm_vendored/node_modules/ffi-napi-v22/lib/ffi.js');
    const libPath = '/home/paul/scm/AetherThings/google-monorepo-sim/target/go/components/nasal/lib/libgonasal.so';
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
