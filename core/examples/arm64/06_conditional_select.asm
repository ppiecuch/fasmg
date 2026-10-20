; ARM64's branchless conditional select: csel/csinc/csinv - computing min/max
; and abs() without any branches at all.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,7
	mov	x1,3
	cmp	x0,x1
	csel	x2,x0,x1,gt		; max(7,3) = 7
	check	x2,7

	csel	x3,x0,x1,lt		; min(7,3) = 3
	check	x3,3

	mov	x4,-5
	cmp	x4,0
	cneg	x5,x4,lt		; abs(-5) = 5
	check	x5,5

	mov	x6,5
	cmp	x6,0
	cneg	x7,x6,lt		; abs(5) = 5 (already positive)
	check	x7,5

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
