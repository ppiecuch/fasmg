
; AArch64 self-hosting scaffold for macOS (port in progress).
; Modeled on core/source/macos/x64/selfhost.inc (the x86-64/SysV variant) but
; targeting the AAPCS64 calling convention, using the Mach-O ARM64 support
; added to examples/x86/include/format/macho.inc and the instruction encoder
; from packages/aarch64/iset/aarch64.inc.
;
; See core/source/macos/arm64/PORTING.md for what's ported and what's left.

include '../../../../packages/aarch64/iset/aarch64.inc'

; CPU_TYPE_ARM64 is also defined inside format/macho.inc itself, but that file
; is only included below - predefine it here so the `MachO.Settings.
; ProcessorType = CPU_TYPE_ARM64` assignment doesn't forward-reference a
; symbol that (for a short/simple source file that converges in very few
; passes) may not yet exist on the pass it's first used.
CPU_TYPE_ARM64 = 0x0100000C	; CPU_TYPE_ARM (12) or CPU_ARCH_ABI64 (0x1000000)

; NOTE: unlike core/source/macos/x64/selfhost.inc, this deliberately does NOT
; wrap `include '.../format/macho.inc'` inside this macro. Empirically, a
; relative `include` written inside a macro *body* resolves against the
; directory of whichever file *invokes* the macro, not the file the macro is
; defined in - the x64 version only gets away with it because its fasmg.asm
; happens to live in the same directory as its selfhost.inc. Since our test
; programs live elsewhere (tests/aarch64-macos/), each one does the format/
; macho.inc include itself, as a plain top-level statement, right after
; calling this macro to set up MachO.Settings.*. See PORTING.md.
macro format?.MachO64? variant
	match , variant
		MachO.Settings.ProcessorType = CPU_TYPE_ARM64
		MachO.Settings.FileType equ MH_OBJECT
	else match =executable?, variant
		MachO.Settings.ProcessorType = CPU_TYPE_ARM64
		; Apple Silicon uses 16KB pages, not the 4KB the x86/x64 self-host
		; builds use - `codesign`'s own page-hash scheme picks up the
		; native page size (confirmed via `codesign -dvvv`: "Page size
		; =16384" even on our 4KB-aligned binary), so segments not
		; aligned to it looked structurally unusual.
		;
		; __PAGEZERO is conventionally a full 4GB on every real 64-bit
		; Mach-O (confirmed against `ld`-linked output) - guards the
		; entire low 32-bit address range against null-pointer-style
		; bugs. BaseAddress doubles as __PAGEZERO's vmsize here.
		MachO.Settings.BaseAddress = 0x100000000
		MachO.Settings.SegmentAlignment = 0x4000
		MachO.Settings.FileAlignment = 0x4000
	else
		err 'invalid argument'
	end match
end macro

macro struct? name
	macro ends?!
			end namespace
		esc end struc
		virtual at 0
			name name
			sizeof.name = $
		end virtual
		purge ends?
	end macro
	esc struc name
		label . : sizeof.name
		namespace .
end macro

; AAPCS64: first 8 integer/pointer arguments in x0-x7, stack 16-byte aligned
; at any `bl`. Our own code keeps sp 16-aligned throughout (stp/ldp pairs
; only), so ccall doesn't need to save/realign sp the way the x86 version does.

iterate reg, x0,x1,x2,x3,x4,x5,x6,x7
	arguments.%? equ reg
end iterate

macro ccall? proc*,args&
	match any, args
		iterate arg, args
			if sizeof (arg)
				adr	arguments.%,arg
			else if ~ arg eq arguments.%
				mov	arguments.%,arg
			end if
		end iterate
	end match
	bl	proc
end macro
