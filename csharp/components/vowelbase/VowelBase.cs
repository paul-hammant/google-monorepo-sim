using System;
using System.Runtime.InteropServices;

namespace Components.VowelBase
{
    public class VowelBase
    {
        [DllImport("libvowelbase.so", CallingConvention = CallingConvention.StdCall)]
        private static extern void Csharp_components_vowelbase_VowelBase_printString(IntPtr env, IntPtr clazz, string input);

        private readonly string _value;

        public VowelBase(string input)
        {
            _value = input;
        }

        public override string ToString()
        {
            Csharp_components_vowelbase_VowelBase_printString(IntPtr.Zero, IntPtr.Zero, _value);
            return "";
        }
    }
}
