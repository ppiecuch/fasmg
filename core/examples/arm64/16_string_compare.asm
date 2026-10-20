; Comparing two NUL-terminated strings byte by byte (like strcmp, but only
; reporting equal/not-equal rather than an ordering).

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; bool my_streq(char *a, char *b) -> x0 = 1 if equal, 0 if not
my_streq:
  loop:
	ldrb	w2,[x0],1
	ldrb	w3,[x1],1
	cmp	w2,w3
	bne	not_equal
	cbnz	w2,loop
	mov	x0,1
	ret
  not_equal:
	mov	x0,0
	ret

  start:
	adr	x0,str_a
	adr	x1,str_b
	bl	my_streq
	check	x0,1			; "fasmg" == "fasmg"

	adr	x0,str_a
	adr	x1,str_c
	bl	my_streq
	check	x0,0			; "fasmg" != "fasmX"

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  str_a db 'fasmg',0
  str_b db 'fasmg',0
  str_c db 'fasmX',0
