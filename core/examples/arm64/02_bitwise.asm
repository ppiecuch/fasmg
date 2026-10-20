; Bitwise operations: AND, ORR, EOR, BIC (and-not), MVN (not).
; (HelloSilicon Chapter 02)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,0xC			; 0b1100
	mov	x1,0xA			; 0b1010
	and	x2,x0,x1		; 1100 & 1010 = 1000
	check	x2,0x8

	orr	x3,x0,x1		; 1100 | 1010 = 1110
	check	x3,0xE

	eor	x4,x0,x1		; 1100 ^ 1010 = 0110
	check	x4,0x6

	bic	x5,x0,x1		; 1100 & ~1010 = 0100
	check	x5,0x4

	mvn	x6,x0
	mvn	x7,x6			; ~~x0 == x0
	checkeq	x7,x0

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
