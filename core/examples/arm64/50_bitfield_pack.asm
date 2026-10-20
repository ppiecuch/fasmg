; Packing several small fields into one word with shifts and masks, then
; unpacking them again - the usual technique for compact flags/registers
; layouts (and for decoding real hardware/ISA encodings, the way this
; whole instruction set's own encoder does internally).
;
; Layout: a made-up 32-bit "pixel": AAAA AAAA RRRR RRRR GGGG GGGG BBBB BBBB
; (alpha, red, green, blue - 8 bits each).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint32_t pack_argb(uint32_t a, uint32_t r, uint32_t g, uint32_t b)
pack_argb:
	lsl	w0,w0,24
	lsl	w1,w1,16
	orr	w0,w0,w1
	lsl	w1,w2,8
	orr	w0,w0,w1
	orr	w0,w0,w3
	ret

  start:
	mov	w0,0xFF			; a
	mov	w1,0x80			; r
	mov	w2,0x40			; g
	mov	w3,0x20			; b
	bl	pack_argb
	movz	w1,0x4020		; expected: 0xFF804020
	movk	w1,0xFF80,lsl 16
	checkeq	w0,w1

	; unpack it back apart
	mov	w4,w0
	lsr	w5,w4,24
	check	w5,0xFF			; alpha

	lsr	w5,w4,16
	and	w5,w5,0xFF
	check	w5,0x80			; red

	lsr	w5,w4,8
	and	w5,w5,0xFF
	check	w5,0x40			; green

	and	w5,w4,0xFF
	check	w5,0x20			; blue

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
