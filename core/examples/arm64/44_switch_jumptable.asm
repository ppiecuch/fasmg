; A computed jump table: what a C switch statement compiles down to once
; there are enough cases to beat a chain of comparisons.
; (HelloSilicon Chapter 04: case.s)
;
; The table holds *relative* offsets (case_N - jump_table), not absolute
; code addresses. This binary is position-independent (MH_PIE); an absolute
; address baked into static data needs a rebase fixup to stay correct once
; ASLR slides the image (macho.inc can now emit those via `internal_ptr` -
; see PORTING.md, "Rebase fixups: gap closed", and
; 52_linked_list_pointers.asm - this found that gap via exactly this
; mistake in an earlier version of 39_linked_list.asm). A same-image
; relative offset needs no fixup at all though, slide or not: add it to
; the table's own runtime address (from `adr`, itself PC-relative and
; always correct) to get the real target - which is also exactly what a
; real C compiler emits for a PIC jump table, fixup support or not.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; uint64_t classify(uint64_t n) : 0->100, 1->200, 2->300, else->999
classify:
	cmp	x0,2
	bhi	case_default
	adr	x1,jump_table
	ldr	w2,[x1,x0,lsl 2]	; relative offset, sign-extended below
	add	x2,x1,w2,sxtw
	br	x2
  case0:
	mov	x0,100
	ret
  case1:
	mov	x0,200
	ret
  case2:
	mov	x0,300
	ret
  case_default:
	mov	x0,999
	ret

  start:
	mov	x0,0
	bl	classify
	check	x0,100

	mov	x0,2
	bl	classify
	check	x0,300

	mov	x0,99
	bl	classify
	check	x0,999

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  jump_table dd case0-jump_table, case1-jump_table, case2-jump_table
