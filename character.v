module vom

// Based on https://docs.rs/nom/7.1.3/nom/character/index.html

// is_alphabetic tests if u8 `b` is ASCII alphabetic: A-Z, a-z.
pub fn is_alphabetic(b u8) bool {
	return 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.bytes().any(it == b)
}

// is_alphanumeric tests if u8 `b` is ASCII alphanumeric: A-Z, a-z, 0-9.
pub fn is_alphanumeric(b u8) bool {
	return is_alphabetic(b) || is_digit(b)
}

// is_digit tests if u8 `b` is ASCII digit: 0-9.
pub fn is_digit(b u8) bool {
	return '0123456789'.bytes().any(it == b)
}

// is_digit tests if u8 `b` is ASCII hex digit: 0-9, A-F, a-f.
pub fn is_hex_digit(b u8) bool {
	return is_digit(b) || 'ABCDEF'.bytes().any(it == b) || 'abcdef'.bytes().any(it == b)
}

// is_newline tests if u8 `b` is ASCII newline: \n.
pub fn is_newline(b u8) bool {
	return b == `\n`
}

// is_oct_digit tests if u8 `b` is ASCII octal digit: 0-7.
pub fn is_oct_digit(b u8) bool {
	return '01234567'.bytes().any(it == b)
}

// is_space tests if u8 `b` is ASCII space or tab.
pub fn is_space(b u8) bool {
	return ' \t'.bytes().any(it == b)
}

// Based on https://docs.rs/nom/7.1.3/nom/character/complete/index.html

// alpha0 recognizes zero or more lowercase and uppercase ASCII alphabetic characters: a-z, A-Z
pub fn alpha0(input string) !(string, string, int) {
	parser := take_while(is_alphabetic)
	return parser(input)
}

// alpha1 recognizes one or more lowercase and uppercase ASCII alphabetic characters: a-z, A-Z
pub fn alpha1(input string) !(string, string, int) {
	parser := take_while1(is_alphabetic)
	return parser(input)
}

// alphanumeric0 recognizes zero or more ASCII numerical and alphabetic characters: 0-9, a-z, A-Z
pub fn alphanumeric0(input string) !(string, string, int) {
	parser := take_while(is_alphanumeric)
	return parser(input)
}

// alphanumeric1 recognizes one or more ASCII numerical and alphabetic characters: 0-9, a-z, A-Z
pub fn alphanumeric1(input string) !(string, string, int) {
	parser := take_while1(is_alphanumeric)
	return parser(input)
}

// character recognizes one letter.
pub fn character(input string) !(string, string, int) {
	parser := take_while_m_n(1, 1, is_alphabetic)
	return parser(input)
}

// crlf recognizes the string '\r\n'.
pub fn crlf(input string) !(string, string, int) {
	parser := tag('\r\n')
	return parser(input)
}

// digit0 recognizes zero or more ASCII numerical characters: 0-9
pub fn digit0(input string) !(string, string, int) {
	parser := take_while(is_digit)
	return parser(input)
}

// digit1 recognizes one or more ASCII numerical characters: 0-9
pub fn digit1(input string) !(string, string, int) {
	parser := take_while1(is_digit)
	return parser(input)
}

// hex_digit0 recognizes zero or more ASCII hexadecimal numerical characters: 0-9, A-F, a-f
pub fn hex_digit0(input string) !(string, string, int) {
	parser := take_while(is_hex_digit)
	return parser(input)
}

// hex_digit1 recognizes one or more ASCII hexadecimal numerical characters: 0-9, A-F, a-f
pub fn hex_digit1(input string) !(string, string, int) {
	parser := take_while1(is_hex_digit)
	return parser(input)
}

// line_ending recognizes an end of line (both '\n' and '\r\n').
pub fn line_ending(input string) !(string, string, int) {
	parser := alt([tag('\n'), tag('\r\n')])
	return parser(input)
}

// multispace0 recognizes zero or more spaces, tabs, carriage returns and line feeds.
pub fn multispace0(input string) !(string, string, int) {
	parser := take_while(fn (b u8) bool {
		return ' \t\n\r'.bytes().any(it == b)
	})
	return parser(input)
}

// multispace1 recognizes one or more spaces, tabs, carriage returns and line feeds.
pub fn multispace1(input string) !(string, string, int) {
	parser := take_while1(fn (b u8) bool {
		return ' \t\n\r'.bytes().any(it == b)
	})
	return parser(input)
}

// newline matches a newline character '\n'
pub fn newline(input string) !(string, string, int) {
	parser := tag('\n')
	return parser(input)
}

// none_of recognizes a character that is not in the provided `pattern`.
pub fn none_of(pattern string) Fn {
	return fn [pattern] (input string) !(string, string, int) {
		if input.len == 0 {
			return error('`none_of` failed because input is empty')
		}
		if pattern.bytes().all(it != input[0]) {
			return input[1..], input[..1], 1
		} else {
			return error('`none_of` failed on input `${input}` with pattern `${pattern}`')
		}
	}
}

// not_line_ending recognizes a string of any char except '\r\n' or '\n'.
pub fn not_line_ending(input string) !(string, string, int) {
	parser := take_while(fn (b u8) bool {
		return '\r\n'.bytes().all(it != b)
	})
	return parser(input)
}

// oct_digit0 recognizes zero or more octal characters: 0-7
pub fn oct_digit0(input string) !(string, string, int) {
	parser := take_while(is_oct_digit)
	return parser(input)
}

// oct_digit1 recognizes one or more octal characters: 0-7
pub fn oct_digit1(input string) !(string, string, int) {
	parser := take_while1(is_oct_digit)
	return parser(input)
}

// one_of recognizes a character that is in the provided `pattern`.
pub fn one_of(pattern string) Fn {
	return fn [pattern] (input string) !(string, string, int) {
		if input.len == 0 {
			return error('`one_of` failed because input is empty')
		}
		if pattern.bytes().any(it == input[0]) {
			return input[1..], input[..1], 1
		} else {
			return error('`one_of` failed on input `${input}` with pattern `${pattern}`')
		}
	}
}

// satisfy recognizes one character and checks that it satisfies a predicate `condition`.
pub fn satisfy(condition fn (u8) bool) Fn {
	return fn [condition] (input string) !(string, string, int) {
		if input.len == 0 {
			return error('`satisfy` failed because input is empty')
		}
		if condition(input[0]) {
			return input[1..], input[..1], 1
		} else {
			return error('`satisfy` failed on input `${input}`')
		}
	}
}

// space0 recognizes zero or more spaces and tabs.
pub fn space0(input string) !(string, string, int) {
	parser := take_while(is_space)
	return parser(input)
}

// space1 recognizes one or more spaces and tabs.
pub fn space1(input string) !(string, string, int) {
	parser := take_while1(is_space)
	return parser(input)
}

// tab matches a tab character '\t'.
pub fn tab(input string) !(string, string, int) {
	parser := tag('\t')
	return parser(input)
}
