package applications.directed_graph_build_systems_are_cool;

import components.nasal.GoNasalLibraryUnZipper;
import components.consonants.C;
import components.fricatives.S;
import components.glides.H;
import components.glides.Y;
import components.nasal.M;
import components.sonorants.L;
import components.sonorants.R;
import components.velar.G;
import components.voiced.B;
import components.voiced.D;
import components.voiceless.P;
import components.voiceless.T;
import components.vowelbase.VowelBase;
import components.vowelbase.VowelBaseLibraryUnZipper;
import components.vowels.A;
import components.vowels.E;
import components.vowels.I;
import components.vowels.O;
import components.vowels.U;

public class DirectedGraphBuildSystemsAreCool {
    private D d;
    private I i;
    private R r;
    private E e;
    private C c;
    private T t;
    private E e2;
    private D d2;
    private G g;
    private R r2;
    private A a;
    private P p;
    private H h;
    private B b;
    private U u;
    private I i2;
    private L l;
    private D d3;
    private S s;
    private Y y;
    private S s2;
    private T t2;
    private E e3;
    private M m;
    private S s3;
    private A a2;
    private R r3;
    private E e4;
    private C c2;
    private O o;
    private O o2;
    private L l2;

    public DirectedGraphBuildSystemsAreCool(D d, I i, R r, E e, C c, T t, E e2, D d2, G g, R r2, A a, P p, H h, B b, U u,
                                            I i2, L l, D d3, S s, Y y, S s2, T t2, E e3, M m, S s3, A a2, R r3, E e4, C
                                                    c2, O o, O o2, L l2) {
        this.d = d;
        this.i = i;
        this.r = r;
        this.e = e;
        this.c = c;
        this.t = t;
        this.e2 = e2;
        this.d2 = d2;
        this.g = g;
        this.r2 = r2;
        this.a = a;
        this.p = p;
        this.h = h;
        this.b = b;
        this.u = u;
        this.i2 = i2;
        this.l = l;
        this.d3 = d3;
        this.s = s;
        this.y = y;
        this.s2 = s2;
        this.t2 = t2;
        this.e3 = e3;
        this.m = m;
        this.s3 = s3;
        this.a2 = a2;
        this.r3 = r3;
        this.e4 = e4;
        this.c2 = c2;
        this.o = o;
        this.o2 = o2;
        this.l2 = l2;
    }

    public static void main(String[] args) throws Exception {

        VowelBaseLibraryUnZipper.unzip();
        VowelBase.loadLibrary();

        GoNasalLibraryUnZipper.unzip();
        GoNasalLibraryUnZipper.loadLibrary();


        System.out.println("main() .. DirectedGraphBuildSystemsAreCool instance created:");
        System.out.flush();
        DirectedGraphBuildSystemsAreCool directedGraphBuildSystemsAreCool = makeDirectedGraphBuildSystemsAreCool();
        // Instantiation would have printed the letters of the class name to the stdout
        System.out.println("\nKey: (vowels via Rust), <nasal via Go>, {sonorants via Kotlin}, all others pure Java\n");
    }

    public static DirectedGraphBuildSystemsAreCool makeDirectedGraphBuildSystemsAreCool() {

        return new DirectedGraphBuildSystemsAreCool(
                new D(), new I(), new R(), new E(), new C(), new T(), new E(),
                new D(), new G(), new R(), new A(), new P(), new H(), new B(),
                new U(), new I(), new L(), new D(), new S(), new Y(), new S(),
                new T(), new E(), new M(), new S(), new A(), new R(), new E(),
                new C(), new O(), new O(), new L()
        );
    }

    @Override
    public String toString() {
        return "DirectedGraphBuildSystemsAreCool{" +
                "d=" + d.getClass() +
                ", i=" + i.getClass() +
                ", r=" + r.getClass() +
                ", e=" + e.getClass() +
                ", c=" + c.getClass() +
                ", t=" + t.getClass() +
                ", e2=" + e2.getClass() +
                ", d2=" + d2.getClass() +
                ", g=" + g.getClass() +
                ", r2=" + r2.getClass() +
                ", a=" + a.getClass() +
                ", p=" + p.getClass() +
                ", h=" + h.getClass() +
                ", b=" + b.getClass() +
                ", u=" + u.getClass() +
                ", i2=" + i2.getClass() +
                ", l=" + l.getClass() +
                ", d3=" + d3.getClass() +
                ", s=" + s.getClass() +
                ", y=" + y.getClass() +
                ", s2=" + s2.getClass() +
                ", t2=" + t2.getClass() +
                ", e3=" + e3.getClass() +
                ", m=" + m.getClass() +
                ", s3=" + s3.getClass() +
                ", a2=" + a2.getClass() +
                ", r3=" + r3.getClass() +
                ", e4=" + e4.getClass() +
                ", c2=" + c2.getClass() +
                ", o=" + o.getClass() +
                ", o2=" + o2.getClass() +
                ", l2=" + l2.getClass() +
                '}';
    }
}
