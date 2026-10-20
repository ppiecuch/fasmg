; Hardware-accelerated CRC32: a single CRC32X instruction folds in 8 bytes
; at once instead of a software table-driven loop. Standard baseline on
; every Apple Silicon core (unlike FEAT_RNG - see aarch64_sy.inc's note on
; that one not actually being present on an M1).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	w0,0xFFFFFFFF		; conventional initial CRC value
	adr	x1,data
	ldr	x2,[x1]
	crc32x	w0,w0,x2
	mvn	w0,w0			; conventional final XOR

	; same computation, one byte at a time, must agree
	mov	w3,0xFFFFFFFF
	mov	x4,x1
	mov	x5,8
  loop:
	ldrb	w6,[x4],1
	crc32b	w3,w3,w6
	subs	x5,x5,1
	cbnz	x5,loop
	mvn	w3,w3

	checkeq	w0,w3

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  align 8
  data dq 0x0123456789ABCDEF
