; Reversing an array in place with two pointers walking toward each other.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,numbers		; left pointer
	adr	x1,numbers
	add	x1,x1,(numbers.count-1)*8	; right pointer
  loop:
	cmp	x0,x1
	bge	reverse_done
	ldr	x2,[x0]
	ldr	x3,[x1]
	str	x3,[x0]
	str	x2,[x1]
	add	x0,x0,8
	sub	x1,x1,8
	b	loop
  reverse_done:

	adr	x4,numbers
	ldr	x5,[x4]
	check	x5,5			; numbers[0] is now what was numbers[4]
	ldr	x5,[x4,32]
	check	x5,1			; numbers[4] is now what was numbers[0]

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  numbers dq 1,2,3,4,5
  numbers.count = 5
