; NEON: adding two vectors of four 32-bit floats in a single instruction,
; using the 128-bit Q/V registers instead of a scalar loop.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,vec_a
	adr	x1,vec_b
	ld1	{v0.4s},[x0]
	ld1	{v1.4s},[x1]
	fadd	v2.4s,v0.4s,v1.4s	; {1,2,3,4} + {10,20,30,40}

	adr	x2,result
	st1	{v2.4s},[x2]

	ldr	w3,[x2]			; result[0] as raw bits of 11.0
	adr	x4,eleven
	ldr	w5,[x4]
	checkeq	w3,w5

	ldr	w3,[x2,12]		; result[3] as raw bits of 44.0
	adr	x4,fortyfour
	ldr	w5,[x4]
	checkeq	w3,w5

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  vec_a dd 1.0,2.0,3.0,4.0
  vec_b dd 10.0,20.0,30.0,40.0
  result dd 0.0,0.0,0.0,0.0
  eleven dd 11.0
  fortyfour dd 44.0
