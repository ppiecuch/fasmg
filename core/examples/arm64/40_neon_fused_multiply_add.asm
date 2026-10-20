; FMLA: fused multiply-accumulate on a whole vector at once - computes
; acc += a*b to full precision in one rounding step (no intermediate
; rounding the way separate fmul+fadd would have), across all 4 lanes.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,acc
	adr	x1,vec_a
	adr	x2,vec_b
	ld1	{v0.4s},[x0]
	ld1	{v1.4s},[x1]
	ld1	{v2.4s},[x2]

	fmla	v0.4s,v1.4s,v2.4s	; acc += a*b, lane by lane

	adr	x3,result
	st1	{v0.4s},[x3]

	ldr	w4,[x3]			; lane 0: 1.0 + 2.0*3.0 = 7.0
	adr	x5,seven
	ldr	w6,[x5]
	checkeq	w4,w6

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  acc dd 1.0,1.0,1.0,1.0
  vec_a dd 2.0,2.0,2.0,2.0
  vec_b dd 3.0,3.0,3.0,3.0
  result dd 0.0,0.0,0.0,0.0
  seven dd 7.0
