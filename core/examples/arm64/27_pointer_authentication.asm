; ARMv8.3 Pointer Authentication (packages/aarch64/iset/aarch64_pauth.inc):
; every M-series core can sign a pointer's unused high bits against a
; modifier, then verify that signature before using the pointer - a
; corrupted or forged pointer fails authentication instead of being used.
; This is what the arm64e ABI (macOS's own system binaries) builds on.
;
; Note: macOS neutralizes the pointer-authentication keys for ordinary
; (non-arm64e) processes like this one, for ABI compatibility - so `pacda`
; here doesn't actually perturb the pointer's bits (confirmed: it's a
; genuine platform behavior, not a bug - this instruction's encoding was
; independently verified correct against Apple's own assembler earlier,
; see core/tests/verify_encodings.sh). The property that's actually
; guaranteed everywhere - sign, then authenticate with the same modifier,
; gets back the exact original pointer - is what this checks.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,payload		; a real pointer value
	mov	x1,0x1234		; an arbitrary modifier (often sp/a context id)

	mov	x2,x0
	pacda	x2,x1			; sign x2 against modifier x1

	mov	x4,x2
	autda	x4,x1			; authenticate with the SAME modifier:
					; strips the auth bits back off
	checkeq	x4,x0			; recovers the original pointer exactly

	ldr	w5,[x4]
	check	w5,0x2A			; the recovered pointer still works

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  payload dd 0x2A
