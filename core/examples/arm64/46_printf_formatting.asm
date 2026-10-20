; Calling libSystem's printf with `ccall` and just a fixed string (no
; %-specifiers) - this is the one case `ccall` (the plain, fixed-argument
; AAPCS64 helper) can correctly make on a variadic function like printf,
; because there are no variadic arguments involved at all.
;
; For printf calls that *do* pass extra arguments for format specifiers,
; see 47_printf_variadic.asm / 48_printf_variadic_mixed.asm and `ccallv` in
; selfhost.inc. Passing those extra arguments the way `ccall` passes normal
; arguments - in x1/x2/... - produces garbage: Apple's arm64 ABI diverges
; from the standard AAPCS64 for variadic calls, and every variadic argument
; must be pushed onto the stack instead (confirmed directly - an earlier
; version of this example did exactly that, and printed wrong numbers even
; though disassembly showed the *registers* held the right values right up
; to the `bl`).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,message
	ccall	printf,x0

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  message db 'Hello from printf!',10,0
