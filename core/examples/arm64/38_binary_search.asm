; Binary search in a sorted array: O(log n) instead of a linear scan.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; int64_t binary_search(int64_t *arr, int64_t count, int64_t target)
; returns the index if found, -1 if not
binary_search:
	mov	x3,0			; lo
	sub	x4,x1,1			; hi
  bsearch_loop:
	cmp	x3,x4
	bgt	not_found
	add	x5,x3,x4
	lsr	x5,x5,1			; mid = (lo+hi)/2
	ldr	x6,[x0,x5,lsl 3]	; arr[mid]
	cmp	x6,x2
	beq	found
	blt	go_right
	sub	x4,x5,1			; target < arr[mid]: search left half
	b	bsearch_loop
  go_right:
	add	x3,x5,1			; target > arr[mid]: search right half
	b	bsearch_loop
  found:
	mov	x0,x5
	ret
  not_found:
	mov	x0,-1
	ret

  start:
	adr	x0,sorted
	mov	x1,sorted.count
	mov	x2,23
	bl	binary_search
	check	x0,3			; sorted[3] == 23

	adr	x0,sorted
	mov	x1,sorted.count
	mov	x2,999
	bl	binary_search
	check	x0,-1			; not present

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  sorted dq 2,9,14,23,41,88
  sorted.count = 6
