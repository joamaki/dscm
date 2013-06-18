
module closure;

import scheme, environment, procedure, pair, objects;

import std.stdio;

bool isClosure(Object o) { return (o && cast(Closure)o); }

class Closure: Procedure {

    Object params, lbody;
    Environment env;

    this (Object params, Object lbody, Environment env) {
	this.params = params;
	this.env = env;

	if (isPair(lbody) && cdr(lbody) is null) {
	    this.lbody = car(lbody);
	} else {
	    this.lbody = cons(new String("begin"), lbody);
        }
    }

    string paramsToString()
    {
	  string ret;
	  if (isPair(params)) {
		foreach (Object p ; cast(Pair)params) {
		      ret ~= getString(p) ~ " ";
		}
	  } else {
		ret ~= getString(params);
	  }

// 	  Object p = params;
// 	  while (p) {
// 		if (!isPair(p)) {
// 		      ret ~= getString(p);
// 		} else {
// 		      ret ~= getString(car(p));
// 		}
// 		p = cdr(p);
// 		if (!(p is null)) ret ~= " ";
// 	  }
	  return ret;
    }

    string toString() {
	  return std.string.format("#<CLOSURE: %x, (%s)>", cast(void*)this, paramsToString());
    }

    Object apply(Scheme scm, Object args) {
	return scm.eval(lbody, new Environment(env, params, args));
    }

}
