; Shift/rotate operations: LSL, LSR, ASR, ROR.
; (HelloSilicon Chapter 02)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,1
	lsl	x1,x0,4			; 1 << 4 = 16
	check	x1,16

	mov	x2,0x80
	lsr	x3,x2,4			; 0x80 >> 4 = 0x8 (logical)
	check	x3,0x8

	mov	x4,-16			; 0xFFFFFFFFFFFFFFF0
	asr	x5,x4,2			; arithmetic shift keeps the sign
	check	x5,-4

	mov	x6,0x1
	ror	x7,x6,1			; rotate right by 1: bit 0 wraps to bit 63
	mov	x8,-1
	lsr	x8,x8,1			; 0x7FFFFFFFFFFFFFFF
	add	x8,x8,1			; 0x8000000000000000
	checkeq	x7,x8

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
