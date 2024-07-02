module vom

// Based on https://docs.rs/nom/7.1.3/nom/combinator/index.html

// all_consuming succeeds if all the input has been consumed by its child parser `f`.
pub fn all_consuming(f Fn) Fn {
	return fn [f] (input string) !(string, string, int) {
		rest, output, len := f(input)!
		if rest.len == 0 {
			return rest, output, len
		} else {
			return error('`all_consuming` failed because ${rest} is not empty')
		}
	}
}

// cond calls the parser `f` if the condition `b` is true.
pub fn cond(b bool, f Fn) Fn {
	return fn [b, f] (input string) !(string, string, int) {
		if b {
			return f(input)
		} else {
			return input, '', 0
		}
	}
}

// eof returns its input if it is at the end of input data
pub fn eof(input string) !(string, string, int) {
	if input.len == 0 {
		return input, input, 0
	} else {
		return error('`eof` failed because ${input} is not empty')
	}
}

// fail return fail.
pub fn fail(input string) !(string, string, int) {
	return error('`fail` failed')
}

/*
// flat_map creates a new parser from the output of the first parser, then apply that parser over the rest of the input.
pub fn flat_map(parser Fn, applied_parser Fn) Fn {
        return fn [parser, applied_parser] (input string) !(string, string) {
                _, a := parser(input) !
		return applied_parser(a) !
        }
}
*/

// not succeeds if the child parser `f` returns an error.
pub fn not(f Fn) Fn {
	return fn [f] (input string) !(string, string, int) {
		f(input) or { return input, '', 0 }
		return error('`not` failed because function succeded')
	}
}

// opt Optional parser: Will return '' if not successful.
pub fn opt(f Fn) Fn {
	return fn [f] (input string) !(string, string, int) {
		rest, output, len := f(input) or { return input, '', 0 }
		return rest, output, len
	}
}

// peek tries to apply its parser `f` without consuming the input.
pub fn peek(f Fn) Fn {
	return fn [f] (input string) !(string, string, int) {
		_, output, len := f(input)!
		return input, output, len
	}
}

// recognize if the child parser `f` was successful, return the consumed input as produced value.
pub fn recognize(f Parser) Fn {
	parsers := [f]
	return fn [parsers] (input string) !(string, string, int) {
		f := parsers[0]
		match f {
			Fn {
				rest, _, len1 := f(input)!
				return rest, input[..input.len - rest.len], len1
			}
			FnMany {
				rest, _, len2 := f(input)!
				return rest, input[..input.len - rest.len], len2
			}
			FnCount {
				return error("`recognize` can't use with FnCount type.")
			}
			FnResult {
				return error("`recognize` can't use with FnResult type.")
			}
		}
	}
}

// value returns the provided value `val` if the child parser `f` succeeds.
pub fn value[T](val T, f Fn) fn (string) !T {
	return fn [val, f] [T](input string) !T {
		f(input) or { return error('`value` fail') }
		return val
	}
}

// verify returns the result of the child parser `first` if it satisfies a verification function `second`.
// The verification function `second` takes as argument a reference to the output of the parser `first`.
pub fn verify(first Fn, second fn (string) bool) fn (string) !string {
	return fn [first, second] (input string) !string {
		_, output, _ := first(input) or { return error('`verify` fail') }
		if second(output) {
			return output
		} else {
			return error('`verify` ${second} fail')
		}
	}
}
