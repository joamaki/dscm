
module main;

import std.stdio, std.c.stdio;
import environment, pair, procedure, primitive, scheme, reader, objects;

const string ver = "0.1";
const string banner = "Welcome to dScm (version " ~ ver ~ "). Copyright (c) 2008 Jussi Mäki.\n";

void main()
{
    Reader reader = new Reader();
    Scheme scm = new Scheme();

    writefln(banner);

    writef("dscm> ");
    while (true) {
	try {
	    Object exp = reader.read();
	    Object res = null;

	    if (exp) res = scm.eval(exp);

	    if (!scm.running()) return;

	    if (cast(Nothing)res) {}
	    else if (res) writef(res);
	    else writef("()");
	} catch (Error e) {
	    writef("Error: %s", e);
	}
	writef("\ndscm> ");
    }
}
