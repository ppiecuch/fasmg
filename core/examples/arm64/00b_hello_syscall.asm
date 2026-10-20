; Diagnostic variant of 00_hello.asm: no dynamic linking at all (no
; LC_LOAD_DYLIB/LC_LOAD_DYLINKER, no imports, no __stubs/__nl_symbol_ptr) -
; raw Darwin BSD syscalls only (`svc #0x80` with the syscall number in x16).
; Used to isolate whether the "Security policy would not allow process"
; kill seen with 00_hello.asm is caused by the Mach-O/LC_MAIN/codesign
; machinery in general, or specifically by the classic indirect-symbol-table
; dynamic-linking setup inherited from the x86 macho.inc code.

include '../../source/macos/arm64/selfhost.inc'

format MachO64 executable
include '../../examples/x86/include/format/macho.inc'

entry start

; `ld` adds both of these for every arm64 main executable even when nothing
; is actually dynamically imported - the kernel/dyld policy checks appear to
; require them regardless of whether the binary ever calls into libSystem.
interpreter '/usr/lib/dyld'
uses '/usr/lib/libSystem.B.dylib'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	mov	x16,4		; SYS_write
	mov	x0,1		; fd = stdout
	adr	x1,message
	mov	x2,message.length
	svc	0x80

	mov	x16,1		; SYS_exit
	mov	x0,0
	svc	0x80

segment '__DATA' readable writable notexecutable

section '__data' align 8

  message db 'hello via raw darwin syscalls',10
  .length = $ - message
