; Recursion with two recursive calls: fib(n) = fib(n-1) + fib(n-2).
; Needs to preserve n and the first recursive result across the second call.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t fib(uint64_t n)
fib:
	cmp	x0,2
	blt	fib_base_case

	stp	x29,x30,[sp,-32]!	; [sp,0]=x29, [sp,8]=x30(lr)
	mov	x29,sp
	str	x19,[sp,16]
	mov	x19,x0

	sub	x0,x19,1
	bl	fib			; x0 = fib(n-1)
	str	x0,[sp,24]		; stash fib(n-1) across the next call

	sub	x0,x19,2
	bl	fib			; x0 = fib(n-2)

	ldr	x1,[sp,24]
	add	x0,x0,x1

	ldr	x19,[sp,16]
	ldp	x29,x30,[sp],32
	ret

  fib_base_case:
	ret				; fib(0)=0, fib(1)=1 - x0 is already n

  start:
	mov	x0,10
	bl	fib
	check	x0,55			; fib(10) = 55

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
