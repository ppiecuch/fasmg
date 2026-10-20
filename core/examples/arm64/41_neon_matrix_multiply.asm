; A NEON-accelerated 4x4 * 4x1 matrix-vector multiply: each output element
; is a dot product of a matrix row with the vector, computed with one
; FMUL + three FMLA per row instead of four separate scalar multiplies and
; adds. (HelloSilicon Chapter 13: matrixmultneon.s does the same thing for
; a full 4x4 * 4x4 matrix multiply.)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,vec
	ld1	{v4.4s},[x0]		; the input vector, reused for every row

	adr	x0,row0
	ld1	{v0.4s},[x0]
	fmul	v5.4s,v0.4s,v4.4s
	faddp	v5.4s,v5.4s,v5.4s
	faddp	v5.4s,v5.4s,v5.4s	; v5.s[0] = dot(row0, vec)

	fmov	w1,s5
	adr	x0,expected0
	ldr	w2,[x0]
	checkeq	w1,w2

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  vec dd 1.0,2.0,3.0,4.0
  row0 dd 1.0,0.0,0.0,1.0	; dot((1,0,0,1),(1,2,3,4)) = 1 + 4 = 5.0
  expected0 dd 5.0
