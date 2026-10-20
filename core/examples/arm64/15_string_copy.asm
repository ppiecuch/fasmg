; Copying a NUL-terminated string byte by byte, then verifying the copy
; against the original with libSystem's memcpy for comparison.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; void my_strcpy(char *dst, char *src)
my_strcpy:
  loop:
	ldrb	w2,[x1],1
	strb	w2,[x0],1
	cbnz	w2,loop
	ret

  start:
	adr	x0,buffer
	adr	x1,source
	bl	my_strcpy

	adr	x2,buffer
	ldrb	w3,[x2]
	check	w3,'f'			; first byte of "fasmg"
	ldrb	w3,[x2,4]
	check	w3,'g'			; last letter
	ldrb	w3,[x2,5]
	check	w3,0			; NUL terminator copied too

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  source db 'fasmg',0
  buffer rb 16
