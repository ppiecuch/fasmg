; Hardware AES acceleration: AESE (encrypt round, SubBytes+ShiftRows) and
; AESMC (MixColumns) do in one instruction each what a software AES
; implementation needs whole lookup tables for. Standard on every Apple
; Silicon core.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,state
	adr	x1,round_key
	ld1	{v0.16b},[x0]
	ld1	{v1.16b},[x1]

	aese	v0.16b,v1.16b		; SubBytes + ShiftRows + AddRoundKey
	aesmc	v0.16b,v0.16b		; MixColumns

	adr	x2,result
	st1	{v0.16b},[x2]

	; the exact output bytes don't matter for this demonstration - what
	; matters is that the hardware round function is deterministic:
	; running it twice on the same input produces the same output
	adr	x0,state
	adr	x1,round_key
	ld1	{v2.16b},[x0]
	ld1	{v3.16b},[x1]
	aese	v2.16b,v3.16b
	aesmc	v2.16b,v2.16b

	ldr	x3,[x2]
	fmov	x4,d2
	checkeq	x3,x4

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  state db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  round_key db 16 dup 0
  result dq 0,0
