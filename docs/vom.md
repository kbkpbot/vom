# module vom
<div align="center"> <h1>vom</h1> </div>

<div align="center">

[![GitHub contributors](https://img.shields.io/github/contributors/knarkzel/vom)](https://github.com/knarkzel/vom/graphs/contributors) [![GitHub issues](https://img.shields.io/github/issues/knarkzel/vom)](https://github.com/knarkzel/vom/issues) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/knarkzel/vom/pulls) [![HitCount](https://views.whatilearened.today/views/github/knarkzel/vom.svg)](https://github.com/knarkzel/vom)

</div>

`vom` is a rewrite of [nom](https://github.com/Geal/nom "nom"), which is a parser combinator library. It is written in V, hence the name.

## Example

[Hexadecimal color](https://developer.mozilla.org/en-US/docs/Web/CSS/color) parser:

```v
module main

import vom { is_hex_digit, tag, take_while_m_n, tuple }

struct Color {
        red   u8
        green u8
        blue  u8
}

fn from_hex(input string) u8 {
        return '0x${input}'.u8()
}

fn hex_primary(input string) !(string, string, int) {
        parser := take_while_m_n(2, 2, is_hex_digit)
        return parser(input)
}

fn hex_color(input string) !(string, Color) {
        discard := tag('#')
        hex_part, _, _ := discard(input)!
        parser := tuple([hex_primary, hex_primary, hex_primary])
        rest, output, _ := parser(hex_part)!
        red, green, blue := from_hex(output[0]), from_hex(output[1]), from_hex(output[2])
        return rest, Color{red, green, blue}
}

fn main() {
        _, color := hex_color('#2F14DF')!
        assert color == Color{47, 20, 223}
        println(color)
}
```

## When will it reach 1.0?

There are some features I both need and want working in V before I will complete this library:

### Generic return type for closures returned from functions

- [Generic return type for closure returned from function doesn't work #13253](https://github.com/vlang/v/issues/13253 "Generic return type for closure returned from function doesn't work #13253")

This is the only feature I absolutely need in order to finish this library. Without it, we're stuck with returning `?(string, string)` instead of `?(string, T)` from each parser, and thus can't construct an Ast with the library alone. That's currently something you need to do manually.

### Generic type aliases

- [Aliases with generic parameters #12702](https://github.com/vlang/v/discussions/12702 "Aliases with generic parameters #12702 ")

Currently this isn't implemented yet. Although it's not required in order to implement the features that are missing, it will make the codebase look horrible without because almost all of the functions depend on following:

```v
type Fn = fn (string) ?(string, string)
type FnMany = fn (string) ?(string, []string)
```

And I need the last argument to be generic, because parsers could return other types such as int, token, []token etc. Although I could search and replace each entry manually, I'm too lazy to do that.

### Functions that return closure that captures functions from function parameter

- [Closures fail when capturing parameters that are functions #13032](https://github.com/vlang/v/issues/13032 "Closures fail when capturing parameters that are functions #13032")

This is not a necessary issue either, but it would remove lots of boilerplate in the current code, for instance from [sequence.v](https://github.com/knarkzel/vom/blob/master/sequence.v "sequence.v").

Adding this would turn following:

```v
pub fn minimal(cond fn (int) bool) fn (int) bool {
	functions := [cond]
	return fn [functions] (input int) bool {
		cond := functions[0]
		return cond(input)
	}
}
```

Into this:

```v
pub fn minimal(cond fn (int) bool) fn (int) bool {
	return fn [cond] (input int) bool {
		return cond(input)
	}
}
```

### Call closure returned from function immediately

- [Closures created from functions can't be called immediately #13051](https://github.com/vlang/v/issues/13051 "Closures created from functions can't be called immediately #13051")

This is again not a mandatory feature for this library to work, but would be a nice addition. Instead of following code:

```v
fn operator(input string, location Location) ?(string, Token) {
	parser := alt([tag('+'), tag('-'), tag('<')])
	rest, output := parser(input) ?
	return rest, Token{output, location, .operator}
}
```

We could write this instead, which is a very common pattern in `nom`:

```v
fn operator(input string, location Location) ?(string, Token) {
	rest, output := alt([tag('+'), tag('-'), tag('<')])(input) ?
	return rest, Token{output, location, .operator}
}
```

## Install

```bash
v install --git https://github.com/knarkzel/vom
```

Then import in your file like so:

```v
import vom
rest, output := vom.digit1('123hello') ?
assert output == '123'
assert rest == 'hello'
```

There are examples in the `examples/` folder.

## Why use vom?

- The parsers are small and easy to write
- The parsers components are easy to reuse
- The parsers components are easy to test separately
- The parser combination code looks close to the grammar you would have written
- You can build partial parsers, specific to the data you need at the moment, and ignore the rest

## Resources

- [nom::recipes](https://docs.rs/nom/7.1.3/nom/recipes/index.html)
- [nom/examples](https://github.com/Geal/nom/tree/main/examples)



## Contents
- [all_consuming](#all_consuming)
- [alpha0](#alpha0)
- [alpha1](#alpha1)
- [alphanumeric0](#alphanumeric0)
- [alphanumeric1](#alphanumeric1)
- [alt](#alt)
- [character](#character)
- [concat](#concat)
- [cond](#cond)
- [count](#count)
- [crlf](#crlf)
- [delimited](#delimited)
- [digit0](#digit0)
- [digit1](#digit1)
- [eof](#eof)
- [escaped](#escaped)
- [fail](#fail)
- [fill](#fill)
- [fold_many0](#fold_many0)
- [fold_many1](#fold_many1)
- [fold_many_m_n](#fold_many_m_n)
- [hex_digit0](#hex_digit0)
- [hex_digit1](#hex_digit1)
- [is_a](#is_a)
- [is_alphabetic](#is_alphabetic)
- [is_alphanumeric](#is_alphanumeric)
- [is_digit](#is_digit)
- [is_hex_digit](#is_hex_digit)
- [is_newline](#is_newline)
- [is_not](#is_not)
- [is_oct_digit](#is_oct_digit)
- [is_space](#is_space)
- [length_count](#length_count)
- [line_ending](#line_ending)
- [many0](#many0)
- [many0_count](#many0_count)
- [many1](#many1)
- [many1_count](#many1_count)
- [many_m_n](#many_m_n)
- [many_till](#many_till)
- [multispace0](#multispace0)
- [multispace1](#multispace1)
- [newline](#newline)
- [none_of](#none_of)
- [not](#not)
- [not_line_ending](#not_line_ending)
- [oct_digit0](#oct_digit0)
- [oct_digit1](#oct_digit1)
- [one_of](#one_of)
- [opt](#opt)
- [pair](#pair)
- [peek](#peek)
- [permutation](#permutation)
- [preceded](#preceded)
- [recognize](#recognize)
- [satisfy](#satisfy)
- [separated_list0](#separated_list0)
- [separated_list1](#separated_list1)
- [separated_pair](#separated_pair)
- [space0](#space0)
- [space1](#space1)
- [tab](#tab)
- [tag](#tag)
- [tag_no_case](#tag_no_case)
- [take](#take)
- [take_till](#take_till)
- [take_till1](#take_till1)
- [take_until](#take_until)
- [take_until1](#take_until1)
- [take_while](#take_while)
- [take_while1](#take_while1)
- [take_while_m_n](#take_while_m_n)
- [terminated](#terminated)
- [tuple](#tuple)
- [value](#value)
- [verify](#verify)
- [Fn](#Fn)
- [FnCount](#FnCount)
- [FnMany](#FnMany)
- [FnResult](#FnResult)
- [Parser](#Parser)

## all_consuming
```v
fn all_consuming(f Fn) Fn
```
all_consuming succeeds if all the input has been consumed by its child parser `f`.

[[Return to contents]](#Contents)

## alpha0
```v
fn alpha0(input string) !(string, string, int)
```
alpha0 recognizes zero or more lowercase and uppercase ASCII alphabetic characters: a-z, A-Z

[[Return to contents]](#Contents)

## alpha1
```v
fn alpha1(input string) !(string, string, int)
```
alpha1 recognizes one or more lowercase and uppercase ASCII alphabetic characters: a-z, A-Z

[[Return to contents]](#Contents)

## alphanumeric0
```v
fn alphanumeric0(input string) !(string, string, int)
```
alphanumeric0 recognizes zero or more ASCII numerical and alphabetic characters: 0-9, a-z, A-Z

[[Return to contents]](#Contents)

## alphanumeric1
```v
fn alphanumeric1(input string) !(string, string, int)
```
alphanumeric1 recognizes one or more ASCII numerical and alphabetic characters: 0-9, a-z, A-Z

[[Return to contents]](#Contents)

## alt
```v
fn alt(parsers []Fn) Fn
```
alt tests a list of `parsers` one by one until one succeeds.

[[Return to contents]](#Contents)

## character
```v
fn character(input string) !(string, string, int)
```
character recognizes one letter.

[[Return to contents]](#Contents)

## concat
```v
fn concat(parsers []Fn) Fn
```
concat applies a tuple of `parsers` one by one and returns their results as a string.

[[Return to contents]](#Contents)

## cond
```v
fn cond(b bool, f Fn) Fn
```
cond calls the parser `f` if the condition `b` is true.

[[Return to contents]](#Contents)

## count
```v
fn count(f Fn, count int) FnMany
```
count runs the embedded parser `f` a specified number `count` of times.

[[Return to contents]](#Contents)

## crlf
```v
fn crlf(input string) !(string, string, int)
```
crlf recognizes the string '\r\n'.

[[Return to contents]](#Contents)

## delimited
```v
fn delimited(first Fn, second Fn, third Fn) Fn
```
delimited matches an object from the `first` parser and discards it, then gets an object from the `second` parser, and finally matches an object from the `third` parser and discards it.

[[Return to contents]](#Contents)

## digit0
```v
fn digit0(input string) !(string, string, int)
```
digit0 recognizes zero or more ASCII numerical characters: 0-9

[[Return to contents]](#Contents)

## digit1
```v
fn digit1(input string) !(string, string, int)
```
digit1 recognizes one or more ASCII numerical characters: 0-9

[[Return to contents]](#Contents)

## eof
```v
fn eof(input string) !(string, string, int)
```
eof returns its input if it is at the end of input data

[[Return to contents]](#Contents)

## escaped
```v
fn escaped(normal Fn, control_char rune, escapable Fn) Fn
```
escaped matches a byte string with escaped characters. The first argument matches the `normal` characters (it must not accept the control character) The second argument is the `control_char` (like \ in most languages) The third argument matches the escaped characters

[[Return to contents]](#Contents)

## fail
```v
fn fail(input string) !(string, string, int)
```
fail return fail.

[[Return to contents]](#Contents)

## fill
```v
fn fill(f Fn, mut buf []string) FnMany
```
fill runs the embedded parser `f` repeatedly, filling the given slice `buf` with results.

[[Return to contents]](#Contents)

## fold_many0
```v
fn fold_many0(f Fn, init fn () []string, g fn (string, mut []string)) FnMany
```
fold_many0 repeats the embedded parser `f`, calling `init` to init, and calling `g` to gather the results.

[[Return to contents]](#Contents)

## fold_many1
```v
fn fold_many1(f Fn, init fn () []string, g fn (string, mut []string)) FnMany
```
fold_many1 repeats the embedded parser `f` at least one time, calling `init` to init, and calling `g` to gather the results.

[[Return to contents]](#Contents)

## fold_many_m_n
```v
fn fold_many_m_n(m usize, n usize, f Fn, init fn () []string, g fn (string, mut []string)) FnMany
```
fold_many_m_n repeats the embedded parser `f` `m`..=`n` times, calling `init` to init, and calling `g` to gather the results.

[[Return to contents]](#Contents)

## hex_digit0
```v
fn hex_digit0(input string) !(string, string, int)
```
hex_digit0 recognizes zero or more ASCII hexadecimal numerical characters: 0-9, A-F, a-f

[[Return to contents]](#Contents)

## hex_digit1
```v
fn hex_digit1(input string) !(string, string, int)
```
hex_digit1 recognizes one or more ASCII hexadecimal numerical characters: 0-9, A-F, a-f

[[Return to contents]](#Contents)

## is_a
```v
fn is_a(pattern string) Fn
```
is_a returns the longest slice that matches any character in the `pattern`.

[[Return to contents]](#Contents)

## is_alphabetic
```v
fn is_alphabetic(b u8) bool
```
is_alphabetic tests if u8 `b` is ASCII alphabetic: A-Z, a-z.

[[Return to contents]](#Contents)

## is_alphanumeric
```v
fn is_alphanumeric(b u8) bool
```
is_alphanumeric tests if u8 `b` is ASCII alphanumeric: A-Z, a-z, 0-9.

[[Return to contents]](#Contents)

## is_digit
```v
fn is_digit(b u8) bool
```
is_digit tests if u8 `b` is ASCII digit: 0-9.

[[Return to contents]](#Contents)

## is_hex_digit
```v
fn is_hex_digit(b u8) bool
```
is_digit tests if u8 `b` is ASCII hex digit: 0-9, A-F, a-f.

[[Return to contents]](#Contents)

## is_newline
```v
fn is_newline(b u8) bool
```
is_newline tests if u8 `b` is ASCII newline: \n.

[[Return to contents]](#Contents)

## is_not
```v
fn is_not(pattern string) Fn
```
is_not parse till any character in `pattern` is met.

[[Return to contents]](#Contents)

## is_oct_digit
```v
fn is_oct_digit(b u8) bool
```
is_oct_digit tests if u8 `b` is ASCII octal digit: 0-7.

[[Return to contents]](#Contents)

## is_space
```v
fn is_space(b u8) bool
```
is_space tests if u8 `b` is ASCII space or tab.

[[Return to contents]](#Contents)

## length_count
```v
fn length_count(f Fn, g Fn) FnMany
```
length_count gets a number from the first parser `f`, then applies the second parser `g` that many times.

[[Return to contents]](#Contents)

## line_ending
```v
fn line_ending(input string) !(string, string, int)
```
line_ending recognizes an end of line (both '\n' and '\r\n').

[[Return to contents]](#Contents)

## many0
```v
fn many0(f Fn) FnMany
```
many0 repeats the embedded parser `f`, gathering the results in a []string.

[[Return to contents]](#Contents)

## many0_count
```v
fn many0_count(f Fn) FnCount
```
many0_count repeats the embedded parser `f`, counting the results

[[Return to contents]](#Contents)

## many1
```v
fn many1(f Fn) FnMany
```
many1 repeats the embedded parser `f`, gathering the results in a []string.

[[Return to contents]](#Contents)

## many1_count
```v
fn many1_count(f Fn) FnCount
```
many1_count repeats the embedded parser `f`, counting the results

[[Return to contents]](#Contents)

## many_m_n
```v
fn many_m_n(m usize, n usize, f Fn) FnMany
```
many_m_n repeats the embedded parser `f` `m`..=`n` times

[[Return to contents]](#Contents)

## many_till
```v
fn many_till(f Fn, g Fn) FnResult
```
many_till applies the parser `f` until the parser `g` produces a result.

[[Return to contents]](#Contents)

## multispace0
```v
fn multispace0(input string) !(string, string, int)
```
multispace0 recognizes zero or more spaces, tabs, carriage returns and line feeds.

[[Return to contents]](#Contents)

## multispace1
```v
fn multispace1(input string) !(string, string, int)
```
multispace1 recognizes one or more spaces, tabs, carriage returns and line feeds.

[[Return to contents]](#Contents)

## newline
```v
fn newline(input string) !(string, string, int)
```
newline matches a newline character '\n'

[[Return to contents]](#Contents)

## none_of
```v
fn none_of(pattern string) Fn
```
none_of recognizes a character that is not in the provided `pattern`.

[[Return to contents]](#Contents)

## not
```v
fn not(f Fn) Fn
```
not succeeds if the child parser `f` returns an error.

[[Return to contents]](#Contents)

## not_line_ending
```v
fn not_line_ending(input string) !(string, string, int)
```
not_line_ending recognizes a string of any char except '\r\n' or '\n'.

[[Return to contents]](#Contents)

## oct_digit0
```v
fn oct_digit0(input string) !(string, string, int)
```
oct_digit0 recognizes zero or more octal characters: 0-7

[[Return to contents]](#Contents)

## oct_digit1
```v
fn oct_digit1(input string) !(string, string, int)
```
oct_digit1 recognizes one or more octal characters: 0-7

[[Return to contents]](#Contents)

## one_of
```v
fn one_of(pattern string) Fn
```
one_of recognizes a character that is in the provided `pattern`.

[[Return to contents]](#Contents)

## opt
```v
fn opt(f Fn) Fn
```
opt Optional parser: Will return '' if not successful.

[[Return to contents]](#Contents)

## pair
```v
fn pair(first Fn, second Fn) FnMany
```
pair gets an object from the `first` parser, then gets another object from the `second` parser.

[[Return to contents]](#Contents)

## peek
```v
fn peek(f Fn) Fn
```
peek tries to apply its parser `f` without consuming the input.

[[Return to contents]](#Contents)

## permutation
```v
fn permutation(parsers []Fn) FnMany
```
permutation applies a list of `parsers` in any order. permutation will succeed if all of the child `parsers` succeeded. It takes as argument a tuple of `parsers`, and returns a tuple of the parser results.

[[Return to contents]](#Contents)

## preceded
```v
fn preceded(first Fn, second Fn) Fn
```
preceded matches an object from the `first` parser and discards it, then gets an object from the `second` parser.

[[Return to contents]](#Contents)

## recognize
```v
fn recognize(f Parser) Fn
```
recognize if the child parser `f` was successful, return the consumed input as produced value.

[[Return to contents]](#Contents)

## satisfy
```v
fn satisfy(condition fn (u8) bool) Fn
```
satisfy recognizes one character and checks that it satisfies a predicate `condition`.

[[Return to contents]](#Contents)

## separated_list0
```v
fn separated_list0(sep Fn, f Fn) FnMany
```
separated_list0 alternates between two parsers to produce a list of elements. `sep` Parses the separator between list elements. `f` Parses the elements of the list.

[[Return to contents]](#Contents)

## separated_list1
```v
fn separated_list1(sep Fn, f Fn) FnMany
```
separated_list1 alternates between two parsers to produce a list of elements. `sep` Parses the separator between list elements. `f` Parses the elements of the list.

[[Return to contents]](#Contents)

## separated_pair
```v
fn separated_pair(first Fn, sep Fn, second Fn) FnMany
```
separated_pair gets an object from the `first` parser, then matches an object from the `sep` parser and discards it, then gets another object from the `second` parser.

[[Return to contents]](#Contents)

## space0
```v
fn space0(input string) !(string, string, int)
```
space0 recognizes zero or more spaces and tabs.

[[Return to contents]](#Contents)

## space1
```v
fn space1(input string) !(string, string, int)
```
space1 recognizes one or more spaces and tabs.

[[Return to contents]](#Contents)

## tab
```v
fn tab(input string) !(string, string, int)
```
tab matches a tab character '\t'.

[[Return to contents]](#Contents)

## tag
```v
fn tag(pattern string) Fn
```
tag recognizes a `pattern`.

[[Return to contents]](#Contents)

## tag_no_case
```v
fn tag_no_case(pattern string) Fn
```
tag_no_case recognizes a case insensitive `pattern`.

[[Return to contents]](#Contents)

## take
```v
fn take(n int) Fn
```
take returns an input slice containing the first `n` input elements (input[..`n`]).

[[Return to contents]](#Contents)

## take_till
```v
fn take_till(condition fn (u8) bool) Fn
```
take_till returns the longest input slice (if any) till a predicate `condition` is met.

[[Return to contents]](#Contents)

## take_till1
```v
fn take_till1(condition fn (u8) bool) Fn
```
take_till1 returns the longest (at least 1) input slice till a predicate `condition` is met.

[[Return to contents]](#Contents)

## take_until
```v
fn take_until(pattern string) Fn
```
take_until returns the input slice up to the first occurrence of the `pattern`.

[[Return to contents]](#Contents)

## take_until1
```v
fn take_until1(pattern string) Fn
```
take_until1 returns the non empty input slice up to the first occurrence of the `pattern`.

[[Return to contents]](#Contents)

## take_while
```v
fn take_while(condition fn (u8) bool) Fn
```
take_while returns the longest input slice (if any) that matches the predicate `condition`.

[[Return to contents]](#Contents)

## take_while1
```v
fn take_while1(condition fn (u8) bool) Fn
```
take_while1 returns the longest (at least 1) input slice that matches the predicate `condition`.

[[Return to contents]](#Contents)

## take_while_m_n
```v
fn take_while_m_n(m int, n int, condition fn (u8) bool) Fn
```
take_while_m_n returns the longest (m <= len <= n) input slice that matches the predicate `condition`.

[[Return to contents]](#Contents)

## terminated
```v
fn terminated(first Fn, second Fn) Fn
```
terminated gets an object from the `first` parser, then matches an object from the `second` parser and discards it.

[[Return to contents]](#Contents)

## tuple
```v
fn tuple(parsers []Fn) FnMany
```
tuple applies a tuple of `parsers` one by one and returns their results as a tuple.

[[Return to contents]](#Contents)

## value
```v
fn value[T](val T, f Fn) fn (string) !T
```
value returns the provided value `val` if the child parser `f` succeeds.

[[Return to contents]](#Contents)

## verify
```v
fn verify(first Fn, second fn (string) bool) fn (string) !string
```
verify returns the result of the child parser `first` if it satisfies a verification function `second`. The verification function `second` takes as argument a reference to the output of the parser `first`.

[[Return to contents]](#Contents)

## Fn
```v
type Fn = fn (string) !(string, string, int)
```
Parser which returns a single value

[[Return to contents]](#Contents)

## FnCount
[[Return to contents]](#Contents)

## FnMany
```v
type FnMany = fn (string) !(string, []string, int)
```
Parser which returns many values

[[Return to contents]](#Contents)

## FnResult
[[Return to contents]](#Contents)

## Parser
```v
type Parser = Fn | FnCount | FnMany | FnResult
```
Core parser type

[[Return to contents]](#Contents)

#### Powered by vdoc. Generated on: 2 Jul 2024 11:15:49
