/* Pair */

module pair;

import objects, scheme;

bool isPair (Object o) { return (o && cast(Pair)o); }

Pair cons (Object a, Object b)
{
    return new Pair (a, b);
}

Pair list (Object a)
{
    return cons(a, null);
}

Object list (Object a, Object b)
{
    return cons(a, cons(b, null));
}

Object car (Object p)
{
    if (!isPair(p)) error("car called on non-pair!");
    return (cast(Pair)p).car();
}

Object cdr (Object p)
{
    if (!isPair(p)) error("cdr called on non-pair!");
    return (cast(Pair)p).cdr();
}

void setCar (Object p, Object x)
{
    if (!isPair(p)) error("setCar called on non-pair!");
    (cast(Pair)p).setCar(x);
}

void setCdr (Object p, Object x)
{
    if (!isPair(p)) error("setCdr called on non-pair!");
    (cast(Pair)p).setCdr(x);
}

Object car (Pair p)
{
    return p.car();
}

Object cdr (Pair p)
{
    return p.cdr();
}

class ImproperListException : Exception
{
      this(char[] msg) {
	    super(msg);
      }
}

class Pair {
    private {
	Object _car, _cdr;
    }

    this(Object a, Object b)
    {
	this._car = a;
	this._cdr = b;
    }

    Object car() {
	return this._car;
    }

    Object cdr() {
	return this._cdr;
    }


    void setCar(Object x) {
	this._car = x;
    }

    void setCdr(Object x) {
	this._cdr = x;
    }

    string toString() {
	string s = "(";
	Object cur = this;

	while (cur) {
	    if (pair.car(cur)) {
		s ~= pair.car(cur).toString();
	    }
	    cur = pair.cdr(cur);

	    // Is this an improper list?
	    if (!isPair(cur)) {
		if (cur) s ~= " . " ~ cur.toString();
		break;
	    }
	    if (cur) s ~= " ";
	}
	s ~= ")";
	return s;
    }

    int opApply (int delegate(ref Object) dg)
    {
	  int res;
	  Object cur = this;
	  while (cur) {
		if (pair.car(cur)) {
		      Object o = pair.car(cur);
		      res = dg(o);
		      if (res) break;
		}
		cur = pair.cdr(cur);

		// Is this an improper list?
		if (!isPair(cur)) {
		      // Can't apply to an improper list!
		      throw new ImproperListException("Cannot apply to an improper list!");
		}
	  }
	  return res;
    }

}

unittest {
    Object a = new String("a");

    Pair p = cons (null, a);

    assert (car(p) is null);
    assert (cdr(p) == a);

}

