; Euclidean distance between two 2D points: sqrt(dx^2 + dy^2), using the
; scalar FSQRT instruction (not a libm call).
; (HelloSilicon Chapter 12: distance.s)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,x1_
	ldr	s0,[x0]
	adr	x0,y1_
	ldr	s1,[x0]
	adr	x0,x2_
	ldr	s2,[x0]
	adr	x0,y2_
	ldr	s3,[x0]

	fsub	s4,s2,s0		; dx = x2 - x1 = 3.0
	fsub	s5,s3,s1		; dy = y2 - y1 = 4.0
	fmul	s4,s4,s4		; dx*dx = 9.0
	fmul	s5,s5,s5		; dy*dy = 16.0
	fadd	s6,s4,s5		; 25.0
	fsqrt	s7,s6			; 5.0

	fcvtzs	w0,s7
	check	w0,5			; a 3-4-5 right triangle

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  x1_ dd 0.0
  y1_ dd 0.0
  x2_ dd 3.0
  y2_ dd 4.0
