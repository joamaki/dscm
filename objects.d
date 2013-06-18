/// Scheme object types

module objects;

import scheme;
import std.string, std.conv;
import std.stdio, std.typetuple;

bool isType(T) (Object o)
{
    return (o && cast(T) o);
}

R getType(T, R) (Object o)
{
    assert (!((cast(T)o) is null));
    return (cast(T) o).v;
}

class True {
    string toString() { return "#t"; }
}
alias isType!(True) isTrue;

class False {
    string toString() { return "#f"; }
}
alias isType!(False) isFalse;

class Okay {
    string toString() { return "okay"; }
}

class Nothing {
    string toString() { return ""; }
}

class String {
    string s;
    this (string s) { this.s = s; }
    string toString () { return s; }
}
bool isString (Object o) { return (o && cast(String)o); }
string getString (Object o) { return (cast(String) o).s; }

/// Raise two numerals to equal types
static void raiseToEqual(inout Numeric a, inout Numeric b)
{
    if (isInteger(a)) {
	if (!isInteger(b)) {
	    a = a.raise();
	    raiseToEqual(a, b);
	}
    } else if (isReal(a)) {
	if (!isReal(b)) {
	    b = b.raise();
	    raiseToEqual(a, b);
	}
    } else if (isRational(a)) {
	if (isInteger(b)) {
	    b = b.raise();
	    raiseToEqual(a, b);
	} else if (isReal(b)) {
	    a = a.raise();
	    raiseToEqual(a, b);
	}
    }
}

alias isType!(Real) isReal;
alias isType!(Integer) isInteger;
alias isType!(Rational) isRational;

abstract class Numeric {
    Numeric raise ();

    Numeric add (Numeric n);
    Numeric sub (Numeric n);
    Numeric div (Numeric n);
    Numeric mul (Numeric n);
    int cmp (Numeric n);

    final Numeric opAdd (Numeric val) {
	raiseToEqual(this, val);
	return add(val);
    }

    final Numeric opSub (Numeric val) {
	raiseToEqual(this, val);
	return sub(val);
    }

    final Numeric opMul (Numeric val) {
	raiseToEqual(this, val);
	return mul(val);
    }

    final Numeric opDiv (Numeric val) {
	raiseToEqual(this, val);
	return div(val);
    }

    final int opCmp (Numeric val) {
	raiseToEqual(this, val);
	return cmp(val);
    }

    final int opEquals (Numeric val) {
	raiseToEqual(this, val);
	return cmp(val) == 0;
    }
}

class Real: Numeric {
    real v;
    alias getType!(Real, real) getReal;

    this (real v) {
	this.v = v;
    }

    Numeric raise() {
	return cast(Numeric)this;
    }

    Numeric add (Numeric val) {
	return new Real(v + getReal(val));
    }

    Numeric sub (Numeric val) {
	return new Real(v - getReal(val));
    }

    Numeric mul (Numeric val) {
	return new Real(v * getReal(val));
    }

    Numeric div (Numeric val) {
	if (getReal(val) == 0.0) error("Divide by zero!");
	return new Real(v / getReal(val));
    }

    int cmp (Numeric val) {
	if (v == getReal(val)) return 0;
	if (v < getReal(val)) return -1;
	else return 1;
    }

    string toString () { return std.string.toString(v); }
}

class Rational: Numeric {
    long numer;
    long denom;

    private long gcd(long x, long y) {
	if (!x) return y;
	else if (x < 0) return gcd(-x, y);
	else if (y < 0) return -gcd(x, -y);
	else return gcd(y % x, x);
    }

    this (long n, long d) {
	long g = gcd(n, d);
	this.numer = n/g;
	this.denom = d/g;
    }

    Numeric raise() {
	return cast(Real) new Real(cast(real)numer / cast(real)denom);
    }

    string toString () {
	if (denom == 1) return std.string.toString(numer);
	else return std.string.toString(numer) ~ "/" ~ std.string.toString(denom);
    }

    Numeric add (Numeric val) {
	Rational v = cast(Rational) val;
	return new Rational(numer*v.denom + v.numer*denom,
			    denom*v.denom);
    }

    Numeric sub (Numeric val) {
	Rational v = cast(Rational) val;
	return new Rational(numer*v.denom - v.numer*denom,
			    denom*v.denom);
    }

    Numeric mul (Numeric val) {
	Rational v = cast(Rational) val;
	return new Rational(numer*v.numer,
			    denom*v.denom);
    }

    Numeric div (Numeric val) {
	Rational v = cast(Rational) val;
	if (v.numer == 0) error("Divide by zero!");
	return new Rational(numer*v.denom,
			    denom*v.numer);
    }

    int cmp (Numeric val) {
	Rational v = cast(Rational) val;

	long n1 = numer * denom * v.denom;
	long n2 = v.numer * denom * v.denom;

	if (n1 == n2) return 0;
	if (n1 < n2) return -1;
	else return 1;
    }


}

class Integer: Numeric {
    long v;
    alias getType!(Integer,long) getInteger;

    this (long v) {
	this.v = v;
    }

    Numeric raise() {
	return cast(Numeric) new Rational(v, 1);
    }

    Numeric add (Numeric val) {
	return new Integer(v + getInteger(val));
    }

    Numeric sub (Numeric val) {
	return new Integer(v - getInteger(val));
    }

    Numeric mul (Numeric val) {
	return new Integer(v * getInteger(val));
    }

    Numeric div (Numeric val) {
	if (getInteger(val) == 0.0) error("Divide by zero!");
	return new Rational(v, getInteger(val));
    }

    int cmp (Numeric val) {
	if (v == getInteger(val)) return 0;
	if (v < getInteger(val)) return -1;
	else return 1;
    }

    string toString () { return std.string.toString(v); }
}

unittest {
    Integer a = new Integer(100);
    Real b = new Real(0.5);
    Rational c = new Rational(10, 3);

    assert ((a+b+c).toString() == "103.833");
    assert ((a*b*c).toString() == "166.667");
    assert ((a-b-c).toString() == "96.1667");
    assert ((a/b/c).toString() == "60");

}

