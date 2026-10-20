; Clamping a value into [lo, hi] using only compare+csel - no branches.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; int64_t clamp(int64_t x, int64_t lo, int64_t hi)
clamp:
	cmp	x0,x1
	csel	x0,x1,x0,lt		; x = max(x, lo)
	cmp	x0,x2
	csel	x0,x2,x0,gt		; x = min(x, hi)
	ret

  start:
	mov	x0,150
	mov	x1,0
	mov	x2,100
	bl	clamp
	check	x0,100			; clamps down

	mov	x0,-50
	mov	x1,0
	mov	x2,100
	bl	clamp
	check	x0,0			; clamps up

	mov	x0,42
	mov	x1,0
	mov	x2,100
	bl	clamp
	check	x0,42			; already in range

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
