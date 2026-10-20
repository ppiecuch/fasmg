; Comparison and conditional branches: cmp + b.cond.
; (HelloSilicon Chapter 04)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,5
	mov	x1,10
	cmp	x0,x1
	blt	x0_less_than_x1
	mov	x2,0			; wrong path
	b	after1
  x0_less_than_x1:
	mov	x2,1
  after1:
	check	x2,1

	cmp	x1,x0
	bgt	x1_greater_than_x0
	mov	x3,0
	b	after2
  x1_greater_than_x0:
	mov	x3,1
  after2:
	check	x3,1

	cmp	x0,x0
	beq	equal_to_self
	mov	x4,0
	b	after3
  equal_to_self:
	mov	x4,1
  after3:
	check	x4,1

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
