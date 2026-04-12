using Components.Greek;
using Components.VowelBase;
using System;

namespace AlgorithmsSolveProblemsInGreek
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // "Algórithmoi lýnoun provlímata"
            Console.WriteLine($"{new Alpha()}{new Lambda()}{new Gamma()}{new VowelBase("O")}{new Rho()}{new VowelBase("I")}{new Theta()}{new Mu()}{new VowelBase("O")}{new VowelBase("I")} {new Lambda()}{new VowelBase("U")}{new Nu()}{new VowelBase("O")}{new VowelBase("U")}{new Nu()} {new Pi()}{new Rho()}{new VowelBase("O")}{new Beta()}{new Lambda()}{new VowelBase("I")}{new Mu()}{new VowelBase("A")}{new Tau()}{new VowelBase("A")}");
        }
    }
}
