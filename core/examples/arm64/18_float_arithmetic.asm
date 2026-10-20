; Scalar single-precision floating point: fadd/fsub/fmul/fdiv, and moving a
; result back to a general register to self-check it (there's no neat
; "check a float register" helper, so convert to int first for 18.5-style
; exact-in-binary values).
; (HelloSilicon Chapter 12)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,ten
	ldr	s0,[x0]
	adr	x0,three
	ldr	s1,[x0]

	fadd	s2,s0,s1		; 10.0 + 3.0 = 13.0
	fcvtzs	w0,s2
	check	w0,13

	fsub	s3,s0,s1		; 10.0 - 3.0 = 7.0
	fcvtzs	w0,s3
	check	w0,7

	fmul	s4,s0,s1		; 10.0 * 3.0 = 30.0
	fcvtzs	w0,s4
	check	w0,30

	fdiv	s5,s0,s1		; 10.0 / 3.0, truncated to int = 3
	fcvtzs	w0,s5
	check	w0,3

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  ten dd 10.0
  three dd 3.0
