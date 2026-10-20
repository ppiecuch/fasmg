; A non-leaf function needs a proper stack frame: save fp/lr (x29/x30) with
; stp on entry, restore with ldp before returning, since it calls another
; function itself (clobbering lr).
; (HelloSilicon Chapter 06)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; int double_it(int x) { return x + x; }
double_it:
	add	x0,x0,x0
	ret

; int quadruple(int x) { return double_it(double_it(x)); }
quadruple:
	stp	x29,x30,[sp,-16]!	; push frame, 16-byte aligned
	mov	x29,sp
	bl	double_it
	bl	double_it
	ldp	x29,x30,[sp],16		; pop frame
	ret

  start:
	mov	x0,5
	bl	quadruple
	check	x0,20

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
