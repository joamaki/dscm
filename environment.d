/* Environment */


module environment;

import scheme, pair, objects;

import std.stdio;

class Environment
{
    private
    {
	/// Parent of this environment or null if global environment
	Environment parent;

	/// Associative array of values
	Object[string] values;
    }

    this (Environment parent)
    {
	this.parent = parent;
    }


    this (Environment parent, Object params, Object args)
    {
	Object param = params;
	Object arg = args;

	this(parent);

	writefln("%s, %s", params, args);

	while (param) {
	    if (!isPair(param)) {
		define (getString(param), args);
		param = null;
		args = null;
		break;
	    } else {
		define(getString(car(param)), car(args));
	    }

	    param = cdr(param);
	    args = cdr(args);
	}

	if (param || args) {
	    error("Invalid amount of arguments!");
	}
    }

    /// Lookup variable in environment
    Object lookup (string var)
    {
	Object *o = (var in values);
	if (o)
	    return *o;
	else if (parent)
	    return parent.lookup(var);
	else {
	    error("Reference to undefined identifier: " ~ var);
	}
    }

    /// Define a variable in this environment
    Object define (string var, Object val)
    {
	return values[var] = val;
    }

    /// Set a variable in this or parent environments
    bool set (string var, Object val)
    {
	if (var in values) {
	    values[var] = val;
	    return true;
	} else if (parent) {
	    return parent.set(var, val);
	} else {
	    return false;
	}
    }
}

unittest
{
      Environment env = new Environment(null);
      Environment env2 = new Environment(env);

      class Test {};
      Test t = new Test, t2 = new Test;

      try {
	  env.lookup("foo");
	  assert(1);
      } catch (Error e) {};

      assert(env.set("foo", t) == false);
      assert(env.define("foo", t) == t);
      assert(env.lookup("foo") == t);
      assert(env.set("foo", t2) == true);
      assert(env.lookup("foo") == t2);


      try {
	  env2.lookup("bar");
	  assert(1);
      } catch (Error e) {};

      assert(env2.lookup("foo") == t2);

      assert(env2.define("bar", t) == t);
      assert(env2.lookup("bar") == t);

      try {
	  env.lookup("bar");
	  assert(1);
      } catch (Error e) {};
}
