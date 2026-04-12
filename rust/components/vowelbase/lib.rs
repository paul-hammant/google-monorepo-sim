use std::io;
use std::io::Write;
use std::ffi::CStr;
use std::os::raw::c_char;
use jni::JNIEnv;
use jni::objects::{JClass, JString};

#[no_mangle]
pub extern "system" fn Java_components_vowelbase_VowelBase_printString(env: JNIEnv, _class: JClass, input: JString) {
    let input: String = env.get_string(input).expect("Couldn't get Java string!").into();
    print!("{}", input);
    io::stdout().flush().unwrap();
}

#[no_mangle]
pub extern "C" fn Csharp_components_vowelbase_VowelBase_printString(_env: *mut std::ffi::c_void, _clazz: *mut std::ffi::c_void, input: *const c_char) {
    vowelbase_print(input);
}

#[no_mangle]
pub extern "C" fn Python_components_vowelbase_printString(input: *const c_char) {
    vowelbase_print(input);
}

fn vowelbase_print(input: *const c_char) {
    let c_str = unsafe { CStr::from_ptr(input) };
    let s = c_str.to_str().unwrap_or("");
    print!("{}", s);
    io::stdout().flush().unwrap();
}
