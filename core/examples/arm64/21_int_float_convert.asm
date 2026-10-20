; Converting between integer and floating point registers: scvtf (signed
; int -> float) and fcvtzs (float -> int, truncating toward zero).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	w0,7
	scvtf	s0,w0			; 7 -> 7.0
	adr	x1,half
	ldr	s1,[x1]
	fmul	s2,s0,s1		; 7.0 * 0.5 = 3.5
	fcvtzs	w2,s2			; truncates to 3
	check	w2,3

	mov	w0,-7
	scvtf	s0,w0			; -7 -> -7.0
	fcvtzs	w2,s0
	check	w2,-7			; round-trips exactly

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  half dd 0.5
