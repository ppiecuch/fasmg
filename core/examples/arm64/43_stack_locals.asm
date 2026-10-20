; Allocating local variables on the stack with `sub sp, sp, #n` (instead of
; the heap or static storage) - the usual home for a function's working
; data, automatically reclaimed on return.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t sum_to_n_via_local_array(uint64_t n) - fills a stack-allocated
; array with 1..n, then sums it, just to exercise local storage
sum_to_n_via_local_array:
	sub	sp,sp,64		; room for 8 uint64_t locals, 16-aligned
	mov	x1,0			; i
  fill_loop:
	cmp	x1,x0
	bge	fill_done
	add	x2,x1,1
	str	x2,[sp,x1,lsl 3]
	add	x1,x1,1
	b	fill_loop
  fill_done:
	mov	x2,0			; sum
	mov	x1,0
  sum_loop:
	cmp	x1,x0
	bge	sum_done
	ldr	x3,[sp,x1,lsl 3]
	add	x2,x2,x3
	add	x1,x1,1
	b	sum_loop
  sum_done:
	mov	x0,x2
	add	sp,sp,64
	ret

  start:
	mov	x0,8
	bl	sum_to_n_via_local_array
	check	x0,36			; 1+2+...+8 = 36

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
