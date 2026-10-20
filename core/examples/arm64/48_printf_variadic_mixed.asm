; ccallv with mixed argument types - an integer, a string pointer, and a
; double - confirming the variadic stack-passing convention handles more
; than just same-typed integers (each still gets a flat 8-byte slot
; regardless of type, per the ABI note in selfhost.inc's ccallv).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x2,42
	adr	x3,word
	adr	x0,pi
	ldr	d0,[x0]
	adr	x1,fmt
	ccallv	printf,x1,x2,x3,d0	; prints "int=42 str=hello float=3.14"

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  fmt db 'int=%lld str=%s float=%.2f',10,0
  word db 'hello',0

  align 8
  pi dq 3.14159
