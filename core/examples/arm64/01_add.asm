; Basic integer arithmetic: add, sub, mul.
; (HelloSilicon Chapter 02: registers and basic data movement/arithmetic)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,5
	mov	x1,3
	add	x2,x0,x1		; 5 + 3 = 8
	check	x2,8

	sub	x3,x0,x1		; 5 - 3 = 2
	check	x3,2

	mov	x4,6
	mov	x5,7
	mul	x6,x4,x5		; 6 * 7 = 42
	check	x6,42

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
