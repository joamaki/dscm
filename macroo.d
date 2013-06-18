
module macroo;

import objects, closure, environment, pair, scheme;

bool isMacro(Object o) { return (o && cast(Macro)o); }

class Macro: Closure {

    this (Object params, Object lbody, Environment env) {
	super(params, lbody, env);
    }

    Pair expand (Scheme scm, Pair old, Object args) {
	Object o = apply(scm, args);
	if (isPair(o)) {
	    Pair ep = cast(Pair) o;
	    old.setCar(ep.car());
	    old.setCdr(ep.cdr());
	} else {
	    old.setCar(new String("begin"));
	    old.setCdr(list(o));
	}
	return old;
    }

    static Object macroExpand (Scheme scm, Object x) {
	if (!isPair(x)) return x;
	Object fn = scm.eval(car(x));
	if (!isMacro(fn)) return x;
	return (cast(Macro)fn).expand(scm, cast(Pair)x, cdr(x));
    }
}
