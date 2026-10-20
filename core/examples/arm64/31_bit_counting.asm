; Bit-counting instructions: CLZ (count leading zeros), RBIT (reverse bit
; order - combine with CLZ to count *trailing* zeros instead).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	w0,1
	clz	w1,w0			; 1 = 0b000...0001, 31 leading zeros (32-bit)
	check	w1,31

	mov	w0,0xFFFFFFFF
	clz	w1,w0			; no leading zeros at all
	check	w1,0

	mov	w0,0x8			; 0b1000 - 3 trailing zeros
	rbit	w2,w0
	clz	w3,w2			; CLZ of the bit-reversed value = trailing zeros
	check	w3,3

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
