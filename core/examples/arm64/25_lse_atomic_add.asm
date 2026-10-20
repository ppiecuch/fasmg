; ARMv8.1 LSE atomics (packages/aarch64/iset/aarch64_lse.inc), mandatory on
; every Apple M-series core: LDADD atomically adds a value to memory and
; returns the *old* value, in a single instruction - no load/compare-swap
; retry loop needed the way a pre-LSE core would require.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,counter
	mov	x1,5
	ldadd	x1,x2,[x0]		; counter += 5, x2 = value *before* the add
	check	x2,100			; old value was 100

	ldr	x3,[x0]
	check	x3,105			; counter is now 105

	mov	x1,1
	staddl	w1,[x0]			; store-only form (release-ordered add):
					; discards the old value, just adds
	ldr	x3,[x0]
	check	x3,106

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  align 8
  counter dq 100
