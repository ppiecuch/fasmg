; NEON horizontal reduction: addv sums all lanes of a vector into one
; scalar, replacing what would otherwise be a 3-instruction scalar loop.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,numbers
	ld1	{v0.4s},[x0]
	addv	s1,v0.4s		; sum all 4 lanes into one scalar
	fmov	w0,s1
	check	w0,100			; 10+20+30+40

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  numbers dd 10,20,30,40
