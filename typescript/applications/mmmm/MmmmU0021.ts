//import * as ffi from 'ffi-napi/lib/ffi'; // Updated import path
import { printExclamation } from 'components/explanation/U0021'; // Import the function

export function main() {
    // Load the Go shared library
    // Path is relative to the compiled JS file in target/applications/mmmm/
    //const libPath = path.join(__dirname, '../../go/components/libnasal/lib/libgonasal.so');
    // const lib = ffi.Library(libPath, {
    //     'Java_components_nasal_M_M_1Init': ['void', []]
    // });

    // lib.Java_components_nasal_M_M_1Init();
    // lib.Java_components_nasal_M_M_1Init();
    // lib.Java_components_nasal_M_M_1Init();
    // lib.Java_components_nasal_M_M_1Init();
    console.log('Mmmm');
    // TODO: flip this from console.log for 'M' to invoking the Go M.go function thru ffi-napi


    // Now call the function to print '!' after the MMMM output
    printExclamation();
}

main();
