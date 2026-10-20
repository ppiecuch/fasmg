; Converting a string to uppercase in place: if a byte is in 'a'..'z',
; clear bit 5 (0x20) to fold it to 'A'..'Z'.
; (HelloSilicon Chapter 05/06/14 all revisit this exact problem)

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; void my_toupper(char *s)
my_toupper:
  loop:
	ldrb	w1,[x0]
	cbz	w1,toupper_done
	cmp	w1,'a'
	blt	skip
	cmp	w1,'z'
	bgt	skip
	and	w1,w1,0xFFFFFFDF	; clear bit 5: 'a'-'z' -> 'A'-'Z'
	strb	w1,[x0]
  skip:
	add	x0,x0,1
	b	loop
  toupper_done:
	ret

  start:
	adr	x0,text
	mov	x19,x0
	bl	my_toupper

	ldrb	w1,[x19]
	check	w1,'F'
	ldrb	w1,[x19,5]
	check	w1,','			; punctuation untouched
	ldrb	w1,[x19,7]
	check	w1,'W'

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  text db 'fasmg, world!',0
