module procedure;

import scheme, objects;

//alias isType!(Procedure) isProcedure;

bool isProcedure(Object o) { return (o && cast(Procedure)o); }


abstract class Procedure  {

    Object apply(Scheme scm, Object args) {
	error("Procedure's apply not overriden!");
	return null;
    }

}



final Procedure proc(Object x) {
    if (x && cast(Procedure)x) return cast(Procedure) x;
    else return null;
}
