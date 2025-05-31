using System;
using System.Runtime.InteropServices;

// Strip off .NET at the start
Console.WriteLine($"{RuntimeInformation.FrameworkDescription.Substring(5)}");