
; ARMv8.1 Large System Extensions (FEAT_LSE) atomic instructions.
;
; Mandatory on every Apple M-series core (M1 through at least M4) - unlike
; the load/store-exclusive retry loops in aarch64_ld_st_tb.inc, these
; complete as a single instruction and are what Apple Silicon (and Rosetta's
; x86 TSO emulation) actually relies on for lock-free code.
;
; Encodings below were derived from the ARM Architecture Reference Manual
; encoding tables and cross-checked instruction-by-instruction against
; Apple's own assembler (`as -arch arm64` from Xcode, disassembled with
; `otool -tV`/`otool -t`) - every mnemonic/operand combination covered here
; was verified to produce an identical 32-bit encoding before being added.

; LDADD/LDCLR/LDEOR/LDSET/LDSMAX/LDSMIN/LDUMAX/LDUMIN, and their ST* aliases
; (same opcode, destination register field forced to the zero register,
; i.e. "store, discard the old value").
;
; Mnemonic shape: LD<op><ord><size>  Rs, Rt, [Xn]      e.g. ldaddalh
;                 ST<op><ord><size>      Rs, [Xn]      e.g. staddl
; <ord> in {"", a, l, al} for LD (acquire/release/acquire-release)
; <ord> in {"", l} for ST (no acquire form - there is no destination
;           register for "acquire" to apply to)
; <size> in {"", b, h} - "" means dispatch on w/x register class (word or
;           doubleword), like `mov`/`ldr` already do elsewhere in this iset.

iterate <op, opc>, add,0x0, clr,0x1, eor,0x2, set,0x3, smax,0x4, smin,0x5, umax,0x6, umin,0x7

    ; --- LD, plain (no acquire/release) ---

    macro ld#op#b Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x38200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    macro ld#op#h Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x78200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    macro ld#op Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0xB8200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	    dd 0xF8200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    ; --- LD, with acquire and/or release ordering ---

    iterate <ord, a, r>, a,1,0, l,0,1, al,1,1

	macro ld#op#ord#b Rs*, Rt*, c&
	    aarch64.parse_adr_f78 c
	    aarch64.parse_operand @op0, Rs
	    aarch64.parse_operand @op1, Rt
	    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
		dd 0x38200000 + (a shl 23) + (r shl 22) + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	    else
		err 'invalid operand'
	    end if
	end macro

	macro ld#op#ord#h Rs*, Rt*, c&
	    aarch64.parse_adr_f78 c
	    aarch64.parse_operand @op0, Rs
	    aarch64.parse_operand @op1, Rt
	    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
		dd 0x78200000 + (a shl 23) + (r shl 22) + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	    else
		err 'invalid operand'
	    end if
	end macro

	macro ld#op#ord Rs*, Rt*, c&
	    aarch64.parse_adr_f78 c
	    aarch64.parse_operand @op0, Rs
	    aarch64.parse_operand @op1, Rt
	    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
		dd 0xB8200000 + (a shl 23) + (r shl 22) + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
		dd 0xF8200000 + (a shl 23) + (r shl 22) + (opc shl 12) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	    else
		err 'invalid operand'
	    end if
	end macro

    end iterate

    ; --- ST aliases: same opcode, Rt forced to the zero register ---

    macro st#op#b Rs*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	if (@op0.type and @type_wn_wzr)
	    dd 0x38200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else
	    err 'invalid operand'
	end if
    end macro

    macro st#op#h Rs*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	if (@op0.type and @type_wn_wzr)
	    dd 0x78200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else
	    err 'invalid operand'
	end if
    end macro

    macro st#op Rs*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	if (@op0.type and @type_wn_wzr)
	    dd 0xB8200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else if (@op0.type and @type_xn_xzr)
	    dd 0xF8200000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else
	    err 'invalid operand'
	end if
    end macro

    macro st#op#l Rs*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	if (@op0.type and @type_wn_wzr)
	    dd 0xB8600000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else if (@op0.type and @type_xn_xzr)
	    dd 0xF8600000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else
	    err 'invalid operand'
	end if
    end macro

    macro st#op#lb Rs*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	if (@op0.type and @type_wn_wzr)
	    dd 0x38600000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else
	    err 'invalid operand'
	end if
    end macro

    macro st#op#lh Rs*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	if (@op0.type and @type_wn_wzr)
	    dd 0x78600000 + (opc shl 12) + (@op0.data shl 16) + @adr.encode + 0x1F
	else
	    err 'invalid operand'
	end if
    end macro

end iterate

; SWP: atomic swap. Shares the same instruction class as LDADD/etc (o3=1,
; opc=000) but has no ST alias.

macro swpb Rs*, Rt*, c&
    aarch64.parse_adr_f78 c
    aarch64.parse_operand @op0, Rs
    aarch64.parse_operand @op1, Rt
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	dd 0x38208000 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro swph Rs*, Rt*, c&
    aarch64.parse_adr_f78 c
    aarch64.parse_operand @op0, Rs
    aarch64.parse_operand @op1, Rt
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	dd 0x78208000 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro swp Rs*, Rt*, c&
    aarch64.parse_adr_f78 c
    aarch64.parse_operand @op0, Rs
    aarch64.parse_operand @op1, Rt
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	dd 0xB8208000 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	dd 0xF8208000 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

iterate <ord, a, r>, a,1,0, l,0,1, al,1,1

    macro swp#ord#b Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x38208000 + (a shl 23) + (r shl 22) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    macro swp#ord#h Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x78208000 + (a shl 23) + (r shl 22) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    macro swp#ord Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0xB8208000 + (a shl 23) + (r shl 22) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	    dd 0xF8208000 + (a shl 23) + (r shl 22) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate

; CAS: compare-and-swap. Mnemonic shape: CAS<ord><size>  Rs, Rt, [Xn]
; (Rs = compare value, Rt = new value / receives the old value on failure)
; <ord> in {"", a, l, al}; <size> in {"", b, h} (word/dword dispatch as above)

macro casb Rs*, Rt*, c&
    aarch64.parse_adr_f78 c
    aarch64.parse_operand @op0, Rs
    aarch64.parse_operand @op1, Rt
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	dd 0x08A07C00 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro cash Rs*, Rt*, c&
    aarch64.parse_adr_f78 c
    aarch64.parse_operand @op0, Rs
    aarch64.parse_operand @op1, Rt
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	dd 0x48A07C00 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro cas Rs*, Rt*, c&
    aarch64.parse_adr_f78 c
    aarch64.parse_operand @op0, Rs
    aarch64.parse_operand @op1, Rt
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	dd 0x88A07C00 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	dd 0xC8A07C00 + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

iterate <ord, l, o0>, a,1,0, l,0,1, al,1,1

    macro cas#ord#b Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x08A07C00 + (l shl 22) + (o0 shl 15) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    macro cas#ord#h Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x48A07C00 + (l shl 22) + (o0 shl 15) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

    macro cas#ord Rs*, Rt*, c&
	aarch64.parse_adr_f78 c
	aarch64.parse_operand @op0, Rs
	aarch64.parse_operand @op1, Rt
	if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
	    dd 0x88A07C00 + (l shl 22) + (o0 shl 15) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
	    dd 0xC8A07C00 + (l shl 22) + (o0 shl 15) + (@op0.data shl 16) + @adr.encode + (@op1.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate
