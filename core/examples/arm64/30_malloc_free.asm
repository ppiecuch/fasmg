; Dynamic memory via libSystem's malloc/free - the heap isn't just for C
; programs, any arm64 Mach-O that links libSystem can use it directly.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x0,64
	ccall	malloc,x0
	mov	x19,x0			; keep the pointer across the next calls
	cmp	x19,0
	bne	malloc_ok
	mov	x20,0
	b	after_malloc_check
  malloc_ok:
	mov	x20,1
  after_malloc_check:
	check	x20,1			; malloc didn't fail

	mov	x1,0x2A
	str	x1,[x19]
	ldr	x2,[x19]
	check	x2,0x2A			; the memory is actually usable

	ccall	free,x19

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages
