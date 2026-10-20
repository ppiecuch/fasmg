; Sign extension: SXTB/SXTH/SXTW widen a smaller signed value to 64 bits,
; propagating the sign bit - needed whenever a byte/halfword/word value
; loaded from memory should be treated as negative.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	w0,0xFF			; byte value -1, but zero-extended in w0
	sxtb	x1,w0			; sign-extend to 64-bit: should become -1
	check	x1,-1

	mov	w0,0xFFFF		; halfword -1
	sxth	x1,w0
	check	x1,-1

	movz	w0,0xFFFF
	movk	w0,0xFFFF,lsl 16	; w0 = 0xFFFFFFFF = -1 as a word
	sxtw	x1,w0
	check	x1,-1

	mov	w0,0x7F			; +127, sign bit clear
	sxtb	x1,w0
	check	x1,127			; stays positive

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
