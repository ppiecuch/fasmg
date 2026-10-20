; A counting loop: sum 1..10 using subs+cbnz (compare-and-branch-if-nonzero).
; (HelloSilicon Chapter 04/06)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,0			; sum
	mov	x1,10			; counter
  loop:
	add	x0,x0,x1
	subs	x1,x1,1
	cbnz	x1,loop

	check	x0,55			; 1+2+...+10 = 55

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
