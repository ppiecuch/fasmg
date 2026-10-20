; Floating point comparison: fcmp sets the NZCV flags, read with the usual
; b.cond/csel - same condition codes as integer cmp.
; (HelloSilicon Chapter 12)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,pt_a
	ldr	s0,[x0]
	adr	x0,pt_b
	ldr	s1,[x0]

	fcmp	s0,s1
	bge	not_less
	mov	x0,1
	b	after
  not_less:
	mov	x0,0
  after:
	check	x0,1			; 2.5 < 4.5

	fcmp	s1,s0
	fcsel	s2,s0,s1,gt		; gt holds from the PREVIOUS fcmp (pt_b>pt_a)
	fcvtzs	w0,s2
	check	w0,2			; min(4.5, 2.5) = 2.5 -> truncated 2

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  pt_a dd 2.5
  pt_b dd 4.5
