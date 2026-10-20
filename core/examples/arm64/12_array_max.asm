; Finding the maximum value in an array, using csel instead of a branch.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,numbers
	mov	x1,numbers.count
	ldr	x2,[x0],8		; max = numbers[0]
	sub	x1,x1,1
  loop:
	ldr	x3,[x0],8
	cmp	x3,x2
	csel	x2,x3,x2,gt
	subs	x1,x1,1
	cbnz	x1,loop

	check	x2,99

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  numbers dq 3,99,17,42,8,51
  numbers.count = 6
