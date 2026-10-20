; Shared boilerplate for the core/examples/arm64/ example suite.
;
; Each example `include`s this, then writes:
;
;   segment '__TEXT' readable executable notwritable
;   section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16
;     start:
;       ... code ...
;       check x0, 42                  ; compare a register to an expected
;                                      ; value, or:
;       checkeq x0, x1                ; compare two registers directly
;       ... more code/checks ...
;       pass                          ; print "PASS\n" and exit 0, once,
;                                      ; at the very end
;   segment '__DATA' readable writable notexecutable
;   section '__data' align 8
;     test_messages                   ; defines pass_msg/fail_msg - put this
;                                      ; once per example, anywhere in its
;                                      ; __data section
;     ... the example's own data ...
;
; This makes an example both a demonstration and a self-checking regression
; test - the normal build-macos.sh "assemble, sign, run, check exit 0" loop
; doubles as the test suite for every one of them.
;
; Why messages live in __DATA, referenced from __TEXT, instead of just
; being declared inline next to where they're used (which would be far less
; boilerplate): empirically, raw `db` data bytes sitting inside a
; `section '__text'` between a conditional branch and its target - even
; completely unreferenced - break fasmg's forward branch-range computation
; ("value out of range" from deep inside the instruction encoder, on what
; should be a trivially short, same-macro-local jump). `__DATA`-based
; messages referenced across segments via `adr`/`ccall` is exactly the
; pattern `00_hello.asm` already proves works, so `check`/`pass` stick to
; it rather than anything living in `__text`.

include '../../source/macos/arm64/selfhost.inc'

format MachO64 executable
include '../../examples/x86/include/format/macho.inc'

entry start

interpreter '/usr/lib/dyld'
uses '/usr/lib/libSystem.B.dylib'

import write,'_write',\
       exit,'_exit',\
       malloc,'_malloc',\
       free,'_free',\
       printf,'_printf',\
       memcpy,'_memcpy',\
       strlen,'_strlen',\
       sqrt,'_sqrt',\
       sysctlbyname,'_sysctlbyname'

; compare a register against an expected constant; on mismatch, print "FAIL"
; and exit 1 right there
macro check reg*, expected*
	local ok
	cmp	reg,expected
	beq	ok
	ccall	write,2,fail_msg,fail_msg.length
	ccall	exit,1
    ok:
end macro

; same as `check`, but for comparing two registers directly
macro checkeq a*, b*
	local ok
	cmp	a,b
	beq	ok
	ccall	write,2,fail_msg,fail_msg.length
	ccall	exit,1
    ok:
end macro

; call once, after every `check`/`checkeq` has passed - prints "PASS" and
; exits 0
macro pass
	ccall	write,1,pass_msg,pass_msg.length
	ccall	exit,0
end macro

; call once, anywhere in the example's own `section '__data'`, to define the
; pass_msg/fail_msg labels `check`/`checkeq`/`pass` above need
macro test_messages
	pass_msg db 'PASS',10
	pass_msg.length = $ - pass_msg
	fail_msg db 'FAIL',10
	fail_msg.length = $ - fail_msg
end macro
