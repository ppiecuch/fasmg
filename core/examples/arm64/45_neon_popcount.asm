; Population count (count of set bits) via NEON: CNT counts bits per-byte
; across a whole vector in one instruction, then ADDV reduces those partial
; counts to a single total - no bit-twiddling loop needed.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint32_t popcount64(uint64_t x)
popcount64:
	fmov	d0,x0
	cnt	v0.8b,v0.8b		; per-byte popcount of the 8 bytes in x0
	addv	b1,v0.8b		; horizontal sum of all 8 byte-counts
	fmov	w0,s1
	ret

  start:
	mov	x0,0xFF			; 8 bits set
	bl	popcount64
	check	w0,8

	mov	x0,0
	bl	popcount64
	check	w0,0

	movz	x0,0xFFFF
	movk	x0,0xFFFF,lsl 16
	movk	x0,0xFFFF,lsl 32
	movk	x0,0xFFFF,lsl 48	; all 64 bits set
	bl	popcount64
	check	w0,64

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
