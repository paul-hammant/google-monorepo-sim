use std::io;
use std::io::Write;
use jni::JNIEnv;
use jni::objects::{JClass, JString};

#[no_mangle]
pub extern "system" fn Java_components_vowelbase_VowelBase_printString(env: JNIEnv, _class: JClass, input: JString) {
    let input: String = env.get_string(input).expect("Couldn't get Java string!").into();
    print!("{}", input);
    io::stdout().flush().unwrap();
}
