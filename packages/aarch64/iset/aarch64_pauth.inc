
; ARMv8.3 Pointer Authentication (FEAT_PAuth) instructions.
;
; Supported by every Apple M-series core - it's what the arm64e ABI macOS
; uses for its own system binaries/kernel is built on, and is available to
; plain arm64 user code too. Signs/authenticates a pointer's high bits
; against a modifier (typically the stack pointer, for return addresses) so
; a corrupted/forged pointer fails authentication rather than being used.
;
; Encodings were derived from the ARM Architecture Reference Manual encoding
; tables and cross-checked instruction-by-instruction against Apple's own
; assembler (`as -arch arm64` from Xcode, disassembled with `otool -t`) -
; every mnemonic/operand combination here was verified to produce an
; identical 32-bit encoding before being added.

; --- Sign/authenticate a register against an explicit modifier register ---
; PAC<key><A|D>  Xd, Xn   - sign Xd using Xn as modifier
; AUT<key><A|D>  Xd, Xn   - authenticate Xd using Xn as modifier
; <key> in {I, D} (instruction-pointer key vs data-pointer key)
; the trailing A/D letter selects the A-key vs the B-key variant

iterate <instr, base>, pacia,0xDAC10000, pacib,0xDAC10400, pacda,0xDAC10800, pacdb,0xDAC10C00,\
			autia,0xDAC11000, autib,0xDAC11400, autda,0xDAC11800, autdb,0xDAC11C00

    macro instr Rd*, Rn*
	aarch64.parse_operand @op0, Rd
	aarch64.parse_operand @op1, Rn
	if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	    dd base + (@op1.data shl 5) + (@op0.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate

; --- Sign/authenticate using an implicit zero modifier ---
; PAC<key><A|D>Z  Xd
; AUT<key><A|D>Z  Xd
; XPACI/XPACD Xd  - strip the authentication code without checking it

iterate <instr, base>, paciza,0xDAC123E0, pacizb,0xDAC127E0, pacdza,0xDAC12BE0, pacdzb,0xDAC12FE0,\
			autiza,0xDAC133E0, autizb,0xDAC137E0, autdza,0xDAC13BE0, autdzb,0xDAC13FE0,\
			xpaci, 0xDAC143E0, xpacd, 0xDAC147E0

    macro instr Rd*
	aarch64.parse_operand @op0, Rd
	if (@op0.type and @type_xn_xzr)
	    dd base + (@op0.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate

; --- Hint-space forms: NOP-compatible on hardware without FEAT_PAuth,
; used in compiler-generated function prologues/epilogues (PACIBSP/AUTIBSP
; bracketing the saved LR) and leaf-function variants (PACIAZ/PACIBZ using
; an implicit zero modifier instead of SP). No operands - all state is
; implicit (LR/SP, or LR/XZR for the Z forms).

iterate <instr, code>, pacia1716,0xD503211F, pacib1716,0xD503215F,\
			autia1716,0xD503219F, autib1716,0xD50321DF,\
			paciasp,  0xD503233F, pacibsp,  0xD503237F,\
			paciaz,   0xD503231F, pacibz,   0xD503235F,\
			autiasp,  0xD50323BF, autibsp,  0xD50323FF,\
			autiaz,   0xD503239F, autibz,   0xD50323DF,\
			xpaclri,  0xD50320FF

    macro instr
	dd code
    end macro

end iterate

; --- Return with authentication: authenticate LR (using SP as modifier)
; then branch to it - replaces a plain `ret` in a PAuth-protected function.

macro retaa
    dd 0xD65F0BFF
end macro

macro retab
    dd 0xD65F0FFF
end macro

; --- Indirect branch with authentication ---
; BRAA/BRAB   Xn, Xm  - authenticate Xn using modifier Xm, then branch
; BRAAZ/BRABZ Xn      - same, with an implicit zero modifier
; BLRAA/BLRAB/BLRAAZ/BLRABZ - call (link) forms of the above

iterate <instr, base>, braa,0xD71F0800, brab,0xD71F0C00, blraa,0xD73F0800, blrab,0xD73F0C00

    macro instr Rn*, Rm*
	aarch64.parse_operand @op0, Rn
	aarch64.parse_operand @op1, Rm
	if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	    dd base + (@op0.data shl 5) + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate

iterate <instr, base>, braaz,0xD61F081F, brabz,0xD61F0C1F, blraaz,0xD63F081F, blrabz,0xD63F0C1F

    macro instr Rn*
	aarch64.parse_operand @op0, Rn
	if (@op0.type and @type_xn_xzr)
	    dd base + (@op0.data shl 5)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate
