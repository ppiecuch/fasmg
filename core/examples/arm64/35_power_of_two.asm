; The classic bit trick: x is a power of two (or zero) iff (x & (x-1)) == 0.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; bool is_power_of_two(uint64_t x) -> x0 = 1 or 0
is_power_of_two:
	cbz	x0,not_pow2		; 0 doesn't count
	sub	x1,x0,1
	and	x1,x0,x1
	cmp	x1,0
	beq	is_pow2
  not_pow2:
	mov	x0,0
	ret
  is_pow2:
	mov	x0,1
	ret

  start:
	mov	x0,64
	bl	is_power_of_two
	check	x0,1

	mov	x0,100
	bl	is_power_of_two
	check	x0,0

	mov	x0,1
	bl	is_power_of_two
	check	x0,1			; 2^0

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
