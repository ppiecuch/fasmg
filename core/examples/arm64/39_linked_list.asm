; A singly linked list represented as an array of {value, next_index} pairs,
; with -1 as the end-of-list marker, instead of raw next-node pointers.
;
; Why indices instead of pointers: a pointer to another internal label
; baked into static data as a flat 64-bit value is an *absolute* address -
; and this binary is position-independent (MH_PIE). Nothing currently
; rebases that value by the ASLR slide dyld actually applies at load time
; (this macho.inc only implements *bind* fixups, for imported symbols - not
; *rebase* fixups, for a binary's own internal pointers; see PORTING.md,
; "Known gap: no rebase fixups"). An index is just a plain integer with no
; such problem, and reads just as naturally for a small fixed list.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t list_sum(node *nodes, int64_t head_index)
list_sum:
	mov	x2,0			; sum
  list_loop:
	cmp	x1,-1
	beq	list_done
	lsl	x3,x1,4			; node index * 16 bytes/node
	add	x3,x0,x3		; x3 = &nodes[i]
	ldr	x4,[x3]			; nodes[i].value
	add	x2,x2,x4
	ldr	x1,[x3,8]		; nodes[i].next_index
	b	list_loop
  list_done:
	mov	x0,x2
	ret

  start:
	adr	x0,nodes
	mov	x1,0			; head is nodes[0]
	bl	list_sum
	check	x0,60			; 10 + 20 + 30

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  ; {value, next_index} pairs; -1 marks the end of the list.
  nodes dq 10,1,\
	    20,2,\
	    30,-1
