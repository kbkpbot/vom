module vom

// Based on https://docs.rs/nom/7.1.3/nom/sequence/index.html

// delimited matches an object from the `first` parser and discards it, then gets an object
// from the `second` parser, and finally matches an object from the `third` parser and
// discards it.
pub fn delimited(first Fn, second Fn, third Fn) Fn {
	return fn [first, second, third] (input string) !(string, string, int) {
		x, _, len1 := first(input)!
		y, output, len2 := second(x)!
		z, _, len3 := third(y)!
		return z, output, len1 + len2 + len3
	}
}

// pair gets an object from the `first` parser, then gets another object from the `second` parser.
pub fn pair(first Fn, second Fn) FnMany {
	return fn [first, second] (input string) !(string, []string, int) {
		a, b, len1 := first(input)!
		c, d, len2 := second(a)!
		return c, [b, d], len1 + len2
	}
}

// preceded matches an object from the `first` parser and discards it, then gets an object
// from the `second` parser.
pub fn preceded(first Fn, second Fn) Fn {
	parsers := [first, second]
	return fn [parsers] (input string) !(string, string, int) {
		first, second := parsers[0], parsers[1]
		x, _, len1 := first(input)!
		y, output, len2 := second(x)!
		return y, output, len1 + len2
	}
}

// separated_pair gets an object from the `first` parser, then matches an object from the `sep` parser
// and discards it, then gets another object from the `second` parser.
pub fn separated_pair(first Fn, sep Fn, second Fn) FnMany {
	return fn [first, sep, second] (input string) !(string, []string, int) {
		mut output := []string{}
		x, start, len1 := first(input)!
		output << start
		y, _, len2 := sep(x)!
		z, end, len3 := second(y)!
		output << end
		return z, output, len1 + len2 + len3
	}
}

// terminated gets an object from the `first` parser, then matches an object from the `second`
// parser and discards it.
pub fn terminated(first Fn, second Fn) Fn {
	return fn [first, second] (input string) !(string, string, int) {
		x, output, len1 := first(input)!
		y, _, len2 := second(x)!
		return y, output, len1 + len2
	}
}

// tuple applies a tuple of `parsers` one by one and returns their results as a tuple.
pub fn tuple(parsers []Fn) FnMany {
	return fn [parsers] (input string) !(string, []string, int) {
		mut temp := input
		mut output := []string{}
		mut total_len := 0
		for parser in parsers {
			rest, slice, len := parser(temp)!
			output << slice
			temp = rest
			total_len += len
		}
		return temp, output, total_len
	}
}

// concat applies a tuple of `parsers` one by one and returns their results as a string.
pub fn concat(parsers []Fn) Fn {
	return fn [parsers] (input string) !(string, string, int) {
		parser := tuple(parsers)
		rest, output, len := parser(input)!
		return rest, output.join(''), len
	}
}
