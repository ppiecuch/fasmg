; Calling printf with real variadic arguments via ccallv, which pushes them
; onto the stack per Darwin's arm64 variadic ABI - see common.inc and
; selfhost.inc's ccallv for why this needs a dedicated helper, and
; 46_printf_formatting.asm for the bug this fixes (ccall alone put the
; arguments in x1/x2, which printf never looks at for its variadic part).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x1,fmt
	mov	x2,6
	mov	x3,7
	ccallv	printf,x1,x2,x3		; prints "6 * 7 = 42\n"

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  fmt db '%lld * %lld = 42',10,0
