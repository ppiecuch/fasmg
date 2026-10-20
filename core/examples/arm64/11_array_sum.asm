; Summing an array of 64-bit integers, indexed addressing with post-index
; increment.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,numbers
	mov	x1,numbers.count
	mov	x2,0			; sum
  loop:
	ldr	x3,[x0],8		; load, then post-increment pointer by 8
	add	x2,x2,x3
	subs	x1,x1,1
	cbnz	x1,loop

	check	x2,150

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  numbers dq 10,20,30,40,50
  numbers.count = 5
