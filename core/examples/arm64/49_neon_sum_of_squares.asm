; Sum of squares of a 4-element float vector via NEON (used for magnitude,
; variance, RMS, etc.): square every lane with one FMUL, then reduce with
; pairwise adds - no scalar loop.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,vec
	ld1	{v0.4s},[x0]
	fmul	v1.4s,v0.4s,v0.4s	; square every lane
	faddp	v1.4s,v1.4s,v1.4s
	faddp	v1.4s,v1.4s,v1.4s	; v1.s[0] = sum of all 4 squares

	fmov	w0,s1
	adr	x1,expected
	ldr	w2,[x1]
	checkeq	w0,w2			; 1^2+2^2+3^2+4^2 = 30

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  vec dd 1.0,2.0,3.0,4.0
  expected dd 30.0
