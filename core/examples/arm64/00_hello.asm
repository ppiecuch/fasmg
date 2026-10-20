; Bring-up test: does a hand-assembled, non-PIE, ad-hoc-signed Mach-O ARM64
; executable actually load and run on Apple Silicon macOS at all?
;
; Exercises, end to end: CPU_TYPE_ARM64 + LC_MAIN (core/examples/x86/include/
; format/macho.inc), the ARM64 import-stub codegen (adrp/ldr/br) added to
; MachO.__stubs, the AAPCS64 ccall convention (core/source/macos/arm64/
; selfhost.inc), and dynamic linking against libSystem.
;
; Expected: prints "hello from native arm64 macos\n" and exits 0.

include '../../source/macos/arm64/selfhost.inc'

format MachO64 executable
include '../../examples/x86/include/format/macho.inc'

entry start

interpreter '/usr/lib/dyld'
uses '/usr/lib/libSystem.B.dylib'

import write,'_write',\
       exit,'_exit'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	ccall	write,1,message,message.length
	ccall	exit,0

segment '__DATA' readable writable notexecutable

section '__data' align 8

  message db 'hello from native arm64 macos',10
  .length = $ - message
