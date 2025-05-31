using Microsoft.VisualStudio.TestTools.UnitTesting;
using AlgorithmsSolveProblemsInGreek;
using Shouldly;
using System;

namespace Applications.Tests
{
    [TestClass]
    public class AlgorithmsSolveProblemsInGreekTests
    {
        [TestMethod]
        public void TestOutput()
        {
            // This test would ideally capture the console output and verify it
            // For simplicity, we are just checking if the program runs without exceptions
            Should.NotThrow(() => Program.Main(new string[] { }));
            Should.NotThrow(() => throw new Exception("should cause vstest to barf"));
        }
    }
}
