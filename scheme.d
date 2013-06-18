
module scheme;

import environment, pair, objects, primitive, procedure, closure, macroo;

import std.stdio, std.string;

class Scheme {
    private {
	/// The global environment
	Environment global;

	bool run = true;
    }

    this() {
	this.global = new Environment(null);
	primitive.install(global);
    }

    bool running() {
	return run;
    }

    void exit() {
	run = false;
    }

    /// Evaluates expression in global environment
    Object eval (Object exp)
    {
	return eval(exp, global);
    }

    /// Evaluates expression in given environment
    Object eval (Object exp, Environment env)
    {
	while (true) {
	    writefln("eval: %s", exp);


	    if (isString(exp)) { // Variable?
		return env.lookup(getString(exp));
	    } else if (!isPair(exp)) { // Self-evaluating?
		return exp;
	    }

	    Object fn = car(exp);
	    Object args = cdr(exp);

	    /// Special forms
	    if (isString(fn)) {
		string s = getString(fn);

		if (s == "quote") {
		    return isPair(args) ? car(args) : args;
		} else if (s == "lambda") {
		    return new Closure(car(args), cdr(args), env);
		}
		if (s == "if") {
		    if (!isFalse( eval(car(args), env)) ) {
			return eval(car(cdr(args)), env);
		    } else
			return eval(car(cdr(cdr(args))), env);
		}
		if (s == "cond") {
		    while (isPair(args) && isPair(car(args))) {
			if (!isFalse (eval(car(car(args)), env))) {
			    if (isPair(cdr(car(args))) && cdr(car(args)))
				return eval(car(cdr(car(args))), env);
			    else // Nothing to evaluate, let's just return true.
				return new True;
			} else {
			    args = cdr(args);
			}
		    }
		    return null;
		}

		if (s == "define") {
		    if (!args) error("Define what?");

		    if (isPair(car(args))) {
			if (!isPair(cdr(args))) error("You can't define that!");
			env.define (getString(car(car(args))),
				    eval(cons(new String("lambda"), cons(cdr(car(args)), cdr(args))), env));
		    } else {
			if (cdr(args) is null) error("Define to what?");
			if (!isString(car(args))) error("You can't define that!");
			env.define (getString(car(args)), eval(car(cdr(args)), env));
		    }
		    return new Okay;
		}

		if (s == "string") {
		    return car(args);
		}

		if (s == "set!") {
		    if (!args) error("Set what?");
		    env.set (getString(car(args)), eval(car(cdr(args)), env));
		    return new Okay;
		}

		if (s == "begin") {
		    writefln("eval begin:%s", args);
		    for (; cdr(args) ; args = cdr(args)) {
			eval (car(args), env);
		    }
		    exp = car(args);
		    continue;
		}

		if (s == "macro") {
		    return new Macro(car(args), cdr(args), env);
		}

	    }

	    /// Function application
	    fn = eval(fn, env);

	    if (isMacro(fn)) {
		exp = (cast(Macro) fn).expand(this, cast(Pair) exp, args);
	    } else if (isClosure (fn)) {
		Closure clos = cast(Closure)fn;
		writefln("eval closure:%s | %s | %s", clos.lbody, args, evalList(args, env));

		exp = clos.lbody;
		env = new Environment(clos.env, clos.params, evalList(args, env));
	    }  else if (isProcedure(fn)) {
		return (cast(Procedure)fn).apply(this, evalList(args, env));
	    } else {
		error(std.string.format("Couldn't evaluate this: %s", fn));
	    }
	}
    }

    /// Construct a list of arguments by evaluating them in given environment
    Pair evalList(Object list, Environment env) {
	if (list is null) return null;
	else if (!isPair(list)) {
	    error("Illegal argument list!");
	} else {
	    return cons (eval (car(list), env), evalList(cdr(list), env));
	}
    }
}


/*** Common functions used everywhere ***/

/// Throws an error object
Object error (string msg)
{
    throw new Error(msg);
}
