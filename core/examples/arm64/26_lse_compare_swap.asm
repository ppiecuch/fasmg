; ARMv8.1 CAS (compare-and-swap): the building block for lock-free data
; structures. Atomically compares memory to an expected value and, if
; equal, replaces it; either way the register comes back holding what was
; actually in memory (so a CAS loop can retry with the fresh value on
; failure, with no separate load needed).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x1,100			; expected value
	mov	x2,200			; new value
	adr	x0,slot
	cas	x1,x2,[x0]		; slot==100? slot=200 : x1=slot's actual value
	check	x1,100			; CAS reports the old value - matched
	ldr	x3,[x0]
	check	x3,200			; swap happened

	mov	x1,999			; wrong expected value this time
	mov	x2,300
	cas	x1,x2,[x0]
	check	x1,200			; CAS reports what was actually there
	ldr	x3,[x0]
	check	x3,200			; no swap happened - x1 didn't match

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  align 8
  slot dq 100
