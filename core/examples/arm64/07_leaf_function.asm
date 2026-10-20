; A "leaf" function (calls nothing else, so needs no stack frame): bl/ret.
; (HelloSilicon Chapter 06)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; int square(int x) { return x * x; }
square:
	mul	x0,x0,x0
	ret

  start:
	mov	x0,9
	bl	square
	check	x0,81

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
