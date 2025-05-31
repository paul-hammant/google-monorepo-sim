using System;
using System.Runtime.InteropServices;

namespace Components.VowelBase
{
    public class VowelBase
    {
        [DllImport("libvowelbase.so", CallingConvention = CallingConvention.StdCall)]
        private static extern void Csharp_components_vowelbase_VowelBase_printString(IntPtr env, IntPtr clazz, string input);

        public VowelBase(string input)
        {
            PrintString(input);
        }

        private void PrintString(string input)
        {
            Csharp_components_vowelbase_VowelBase_printString(IntPtr.Zero, IntPtr.Zero, input);
        }
    }
}
