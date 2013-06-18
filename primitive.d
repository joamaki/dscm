/* Scheme primitives */

module primitive;

import std.stdio;

import scheme, procedure, environment, pair, objects;

/// Function prototype for a primitive
alias Object function(string name, Scheme scm, Object args) primfn;

class Primitive: Procedure {
    private {
	primfn fn;
	string name;
    }

    this (string name, primfn fn)
    {
	this.fn = fn;
	this.name = name;
    }

    Object apply (Scheme scm, Object args)
    {
	return fn (name, scm, args);
    }

    string toString() {
	return std.string.format("#<PRIMITIVE: %x>", cast(void*)this);
    }
}

Object doAritmetic(string name, Scheme scm, Object args)
{
    if (!isPair(args)) {
	if (name[0] == '*' || name[0] == '/')
	    return new Integer(1);
	else
	    return new Integer(0);
    }

    Numeric res = cast(Numeric) car(args);
    args = cdr(args);

    while (isPair(args)) {
	Numeric n = cast(Numeric) car(args);
	assert (!(n is null));
	args = cdr(args);

	switch (name[0]) {
	case '+': res = res + n; break;
	case '-': res = res - n; break;
	case '/': res = res / n; break;
	case '*': res = res * n; break;
	}
    }
    return res;
}

Object doCompare(string name, Scheme scm, Object args)
{
    if (!isPair(args) || !isPair(cdr(args))) {
	error("Need at least 2 arguments!");
    }

    Numeric prev = cast(Numeric) car(args);

    args = cdr(args);
    while (isPair(args)) {
	Numeric val = cast(Numeric) car(args);

	if (name == "=") {
	    if (prev != val) return new False;
	} else if (name == "!=") {
	    if (prev == val) return new False;
	} else if (name == "<") {
	    if (prev >= val) return new False;
	} else if (name == "<=") {
	    if (prev > val) return new False;
	} else if (name == ">") {
	    if (prev <= val) return new False;
	} else if (name == ">=") {
	    if (prev < val) return new False;
	}
	prev = cast(Numeric) car(args);
	args = cdr(args);
    }
    return new True;
}


void install (Environment env)
{
    void defPrim (string name, primfn fn)
    {
	env.define(name, new Primitive(name, fn));
    }

    foreach (n ; ["*", "-", "+", "/", "%"])
	defPrim(n, &doAritmetic);

    foreach (n ; ["=", ">", ">=", "<", "<="])
	defPrim(n, &doCompare);

    defPrim("car",
	    function Object (string name, Scheme scm, Object args) {
		return car(car(args));
	    });

    defPrim("cdr",
	    function Object (string name, Scheme scm, Object args)
	    {
		return cdr(car(args));
	    });

    defPrim("cons",
	    function Object (string name, Scheme scm, Object args)
	    {
		return cons(car(args), car(cdr(args)));
	    });

    defPrim("exit",
	    function Object (string name, Scheme scm, Object args)
	    {
		writefln("\nSo Long, and Thanks for all the Lambda!");
		scm.exit();
		return new Nothing;
	    });

    defPrim("display",
	    function Object (string name, Scheme scm, Object args)
	    {
		if (!isPair(args)) {
		    error("display needs at least one argument!");
		} else {
		    if (cdr(args)) {
			error("Ports not implemented yet");
		    }
		    writef("%s", car(args));
		}
		return new Nothing;
	    });

    defPrim("newline",
	    function Object (string name, Scheme scm, Object args)
	    {
		if (args) {
		    error("Ports not implemented yet");
		}

		writefln();
		return new Nothing;
	    });

    defPrim("typeof",
	    function Object (string name, Scheme scm, Object args) {
		return new String(car(args).classinfo.name);
	    });

    defPrim("real?",
	    function Object (string name, Scheme scm, Object args) {
		if (isReal(car(args))) return new True;
		else return new False;
	    });


    defPrim("integer?",
	    function Object (string name, Scheme scm, Object args) {
		if (isInteger(car(args))) return new True;
		else return new False;
	    });


    defPrim("rational?",
	    function Object (string name, Scheme scm, Object args) {
		if (isRational(car(args))) return new True;
		else return new False;
	    });

    defPrim("apply",
	    function Object (string name, Scheme scm, Object args) {
        writefln("Applying: %s", args);
        if (!isPair(car(cdr(args))))
            error("Apply expects list as a second argument!");
		return proc(car(args)).apply(scm, car(cdr(args)));
	    });

    defPrim("null?",
	    function Object (string name, Scheme scm, Object args) {
		if (car(args) is null) return new True;
		else return new False;
	    });

    defPrim("append",
	    function Object (string name, Scheme scm, Object args) {
		if (!isPair(args)) return null;
		if (cdr(args) is null) return car(args);

		Object lst, lst1st;
		while (isPair(args)) {
		    Object cur = car(args);
		    while (isPair(cur)) {
			if (!lst) lst1st = lst = list(car(cur));
			else {
			    setCdr(lst, list(car(cur)));
			    lst = cdr(lst);
			}
			cur = cdr(cur);
		    }
		    args = cdr(args);
		}
		return lst1st;
	    });



    env.define("null", null);
    env.define("else", new True);
}
