; Recursion: factorial(n) = n * factorial(n-1), base case factorial(0) = 1.
; Each recursive call needs its own stack frame to save x29/x30 and the
; argument n across the nested call.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t factorial(uint64_t n)
factorial:
	stp	x29,x30,[sp,-32]!
	mov	x29,sp
	str	x19,[sp,16]		; x19 is callee-saved, holds n across the call

	cbnz	x0,recurse
	mov	x0,1			; factorial(0) = 1
	b	factorial_done
  recurse:
	mov	x19,x0
	sub	x0,x0,1
	bl	factorial		; x0 = factorial(n-1)
	mul	x0,x0,x19		; x0 = n * factorial(n-1)
  factorial_done:
	ldr	x19,[sp,16]
	ldp	x29,x30,[sp],32
	ret

  start:
	mov	x0,5
	bl	factorial
	check	x0,120			; 5! = 120

	mov	x0,0
	bl	factorial
	check	x0,1			; 0! = 1

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
