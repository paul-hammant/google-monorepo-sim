package applications.monorepos_rule;

import components.fricatives.S;
import components.nasal.GoNasalLibraryUnZipper;
import components.nasal.M;
import components.nasal.N;
import components.sonorants.L;
import components.sonorants.R;
import components.voiceless.P;
import components.vowelbase.VowelBase;
import components.vowelbase.VowelBaseLibraryUnZipper;
import components.vowels.E;
import components.vowels.O;
import components.vowels.U;

public class MonoreposRule {
    private M m;
    private O o;
    private N n;
    private O o2;
    private R r;
    private E e;
    private P p;
    private O o3;
    private S s;
    private R r2;
    private U u;
    private L l;
    private E e2;

    public MonoreposRule(M m, O o, N n, O o2, R r, E e, P p, O o3, S s, R r2, U u, L l, E e2) {
        this.m = m;
        this.o = o;
        this.n = n;
        this.o2 = o2;
        this.r = r;
        this.e = e;
        this.p = p;
        this.o3 = o3;
        this.s = s;
        this.r2 = r2;
        this.u = u;
        this.l = l;
        this.e2 = e2;
    }

    public static void main(String[] args) throws Exception {

        VowelBaseLibraryUnZipper.unzip();
        VowelBase.loadLibrary();

        GoNasalLibraryUnZipper.unzip();
        GoNasalLibraryUnZipper.loadLibrary();

        System.out.println("main() .. MonoreposRule instance created:");
        System.out.flush();
        MonoreposRule monoreposRule = makeMonoreposRule();
        // Instantiation would have printed the letters of the class name to the stdout
        System.out.println("\nMonoreposRule instance toString():");
        System.out.println(monoreposRule);
    }

    public static MonoreposRule makeMonoreposRule() {
        return new MonoreposRule(
                new M(), new O(), new N(), new O(), new R(), new E(), new P(),
                new O(), new S(), new R(), new U(), new L(), new E()
        );
    }

    @Override
    public String toString() {
        return "MonoreposRule{" +
                "m=" + m.getClass() +
                ", o=" + o.getClass() +
                ", n=" + n.getClass() +
                ", o2=" + o2.getClass() +
                ", r=" + r.getClass() +
                ", e=" + e.getClass() +
                ", p=" + p.getClass() +
                ", o3=" + o3.getClass() +
                ", s=" + s.getClass() +
                ", r2=" + r2.getClass() +
                ", u=" + u.getClass() +
                ", l=" + l.getClass() +
                ", e2=" + e2.getClass() +
                '}';
    }
}
