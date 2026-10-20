; Calling libSystem's printf with just a fixed string (no %-specifiers).
;
; Note on what *doesn't* work here: passing extra arguments for format
; specifiers (e.g. printf("%lld", x1)) the way `ccall` passes normal
; arguments - in x1/x2/... - produces garbage. Confirmed directly: an
; earlier version of this example did exactly that and printed wrong
; numbers, verified by disassembly that the *registers* held the right
; values right up to the `bl`. The actual cause: Apple's arm64 ABI diverges
; from the standard AAPCS64 for variadic calls - only the named parameter
; (the format string) uses the normal register convention; every variadic
; argument after it must be pushed onto the stack instead, packed with no
; padding, the way i386's calling convention works. `ccall`/`check`/`pass`
; here only implement the standard fixed-argument convention, so calling a
; variadic function with extra arguments needs a dedicated stack-argument
; helper that doesn't exist yet - out of scope for this example suite.

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
