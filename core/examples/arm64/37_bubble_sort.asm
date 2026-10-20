; Bubble sort: the classic O(n^2) sort, as a nested loop over an array.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x19,numbers
	mov	x20,numbers.count

	sub	x0,x20,1		; outer loop count: n-1 passes
  outer:
	cbz	x0,sorted
	mov	x1,x19			; pointer walking this pass
	sub	x2,x20,1		; comparisons this pass (decreases isn't
					; required for correctness, just a fixed
					; n-1 - simple over clever)
  inner:
	cbz	x2,outer_next
	ldr	x3,[x1]
	ldr	x4,[x1,8]
	cmp	x3,x4
	ble	no_swap
	str	x4,[x1]
	str	x3,[x1,8]
  no_swap:
	add	x1,x1,8
	sub	x2,x2,1
	b	inner
  outer_next:
	sub	x0,x0,1
	b	outer
  sorted:

	ldr	x1,[x19]
	check	x1,8			; smallest first
	ldr	x1,[x19,32]
	check	x1,99			; largest last

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  numbers dq 42,8,99,17,23
  numbers.count = 5
