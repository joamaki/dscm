/** The reader of the read-eval-print-loop */

module reader;

import objects, scheme, pair;
import std.stdio, std.cstream, std.stream, std.string, std.conv;

class Reader {

    private {
	Stream input;
	Object thisNext = null;
    }

    this () {
	input = std.cstream.din;
    }

    string charToString(char c)
    {
	return [c, '\0'];
    }

    Object nextToken()
    {
	if (thisNext) {
	    Object t = thisNext;
	    thisNext = null;
	    return t;
	}

	if (input.eof())
	    return null;

	char c = input.getc();

	while (std.string.iswhite(c) && !input.eof()) c = input.getc();

	switch (c) {
	case '(':
	case ')':
	case '\'':
	case '`':
	    return new String (charToString(c));

	case '"': // string
	    char buf[];
	    buf ~= c;
	    do {
		c = input.getc();
		buf ~= c;
	    } while (!input.eof() && c != '"');
	    buf ~= c;
	    return new String(chop(buf));

	case ';': // comment
	    while (!input.eof() && c != '\n' && c != '\r') c = input.getc();
	    return nextToken();

	case '#':
	    c = input.getc();
	    if (c == 't') return new True;
	    else if (c == 'f') return new False;
	    else if (c == '(') error("vectors not yet implemented!");
	    else error("not implemented!");

	default:
	    char buf[];

	    int fstch = c;
	    do {
		// todo optimize
		buf ~= [c];
		c = input.getc();
	    } while (!std.string.iswhite(c) && !input.eof() && c != '(' && c != ')' &&
		     c != '\'' && c != ';' && c != '"' && c != ',' && c != '`');
	    buf ~= ['\0'];

	    input.ungetc(c);
	    if (fstch == '.' || fstch == '+' || fstch == '-' || std.string.isdigit(fstch))
		try { return new Integer (toLong(chop(buf))); } catch (Error e) {
		    try { return new Real (toReal(chop(buf))); } catch (Error e) {}
		    //writefln("Error converting buffer: %s: %s", buf, e);
		}

	    return new String (chop(buf));
	}
    }

    public Object readList ()
    {
	Object token = nextToken();
	if (!token) return null;

	if (isString(token)) {
	    string s = getString(token);

	    if (s[0] == ')') {
		return null;
	    }

	    if (s[0] == '.') {
		writefln("variadic!");
		Object res = read();
		token = nextToken();
		if (isString(token)) {
		    s = getString(token);
		    if (s[0] != ')')
			error("Missing ')'.");
		}
		return res;
	    }
	}

	thisNext = token;
	Object fst = read();
	Object rst = readList();
	return cons (fst, rst);
    }

    /// Read and return a scheme expression or null on EOF.
    public Object read ()
    {
	Object token = nextToken();
	if (!token) return null;

	if (isString(token)) {
	    string s = getString(token);
	    switch (s[0]) {
	    case '(':
		return readList();
	    case ')':
		error("Extra ) in input!");
	    case '\'':
		return list(new String("quote"), read());
	    case '`':
		return list(new String("quasiquote"), read());
	    case ',':
		return list(new String("unquote"), read());

	    case '"':
		return list(new String("string"), token);

	    default:
		if (s == ",@")
		    return list(new String("unquote-splicing"), read());
		else
		    return token;
	    }
	}
	return token;
    }
}
