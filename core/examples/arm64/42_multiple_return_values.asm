; AAPCS64 allows returning small multi-value results directly in x0/x1 (no
; hidden pointer needed) - e.g. a function returning both a quotient and a
; remainder.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; void divmod(uint64_t a, uint64_t b) -> x0 = a/b, x1 = a%b
divmod:
	udiv	x2,x0,x1
	msub	x3,x2,x1,x0
	mov	x0,x2
	mov	x1,x3
	ret

  start:
	mov	x0,17
	mov	x1,5
	bl	divmod
	check	x0,3			; 17/5 = 3
	check	x1,2			; 17%5 = 2

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
