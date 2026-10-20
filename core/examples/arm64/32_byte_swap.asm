; REV: byte-swap a register - the usual way to convert between big-endian
; (network byte order) and little-endian (native on arm64) values.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	movz	w0,0x5678
	movk	w0,0x1234,lsl 16	; w0 = 0x12345678
	rev	w1,w0			; byte-swap: 0x78563412
	movz	w2,0x3412
	movk	w2,0x7856,lsl 16
	checkeq	w1,w2

	rev	w3,w1			; swapping twice recovers the original
	checkeq	w3,w0

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
