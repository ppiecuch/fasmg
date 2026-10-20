; Euclid's algorithm for greatest common divisor, using UDIV+MSUB to compute
; the remainder (a % b = a - (a/b)*b) in two instructions instead of one.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t gcd(uint64_t a, uint64_t b)
gcd:
	cbz	x1,gcd_done
	udiv	x2,x0,x1
	msub	x3,x2,x1,x0		; x3 = x0 - x2*x1 = a mod b
	mov	x0,x1
	mov	x1,x3
	b	gcd
  gcd_done:
	ret

  start:
	mov	x0,48
	mov	x1,18
	bl	gcd
	check	x0,6

	mov	x0,17
	mov	x1,5
	bl	gcd
	check	x0,1			; coprime

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
