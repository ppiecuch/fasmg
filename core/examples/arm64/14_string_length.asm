; Computing a NUL-terminated string's length by hand (byte at a time), then
; checking it against libSystem's own strlen() for agreement.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t my_strlen(char *s)
my_strlen:
	mov	x1,x0
  loop:
	ldrb	w2,[x1],1
	cbnz	w2,loop
	sub	x0,x1,x0
	sub	x0,x0,1			; don't count the NUL terminator
	ret

  start:
	adr	x0,hello
	bl	my_strlen
	check	x0,13			; "Hello, world!" is 13 chars

	adr	x0,hello
	ccall	strlen,x0
	check	x0,13			; agrees with libSystem's strlen

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  hello db 'Hello, world!',0
