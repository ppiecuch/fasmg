; A singly linked list built out of *real* internal pointers (node.next holds
; the runtime address of the following node) instead of the array-index
; trick 39_linked_list.asm had to use. This is only safe under this binary's
; MH_PIE/ASLR load because every node.next slot is declared with
; `internal_ptr`, not a plain `dq label` - macho.inc now emits a real
; dyld rebase fixup for each one, chained together with any `import`
; binds in the same __DATA page, so dyld slides every one of these
; pointers by the same amount it slides the whole image (see PORTING.md,
; "Rebase fixups: gap closed"). Run this several times in a row (not under
; lldb, which disables ASLR by default) to confirm it isn't passing only by
; coincidence of a zero slide.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t list_sum(node *head) - node is {int64_t value, node *next}
list_sum:
	mov	x2,0			; sum
  list_loop:
	cbz	x0,list_done
	ldr	x3,[x0]			; node->value
	add	x2,x2,x3
	ldr	x0,[x0,8]		; node->next
	b	list_loop
  list_done:
	mov	x0,x2
	ret

  start:
	adr	x0,node1
	bl	list_sum
	check	x0,60			; 10 + 20 + 30

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  ; test_messages (PASS\n + FAIL\n = 10 bytes) doesn't end on an 8-byte
  ; boundary - internal_ptr's rebase slots need natural pointer alignment
  ; (the macro re-aligns defensively, but keeping node1 itself aligned too
  ; is what keeps this struct's field offsets matching what the code below
  ; assumes).
  align 8

  node1 dq 10
	internal_ptr node2
  node2 dq 20
	internal_ptr node3
  node3 dq 30
	dq 0				; end of list - a real null, not a fixup
