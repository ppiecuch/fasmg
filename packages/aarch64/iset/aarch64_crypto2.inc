
; ARMv8.2 SHA-512, SHA-3, and SM4 cryptographic extensions.
;
; Not verified present on any particular Apple Silicon generation (these are
; all *optional* ARM extensions - see the RNDR lesson in aarch64_sy.inc for
; why that distinction matters) - included here for ISA completeness, same
; as the base SHA1/SHA256/AES support already in aarch64_done.inc.
;
; Not implemented: SM3SS1's sibling SM3TT1A/SM3TT1B/SM3TT2A/SM3TT2B, which
; need a `Vm.S[index]` element-indexed operand - no operand parser in this
; iset handles indexed vector-by-element operands yet (the same gap noted
; in aarch64_dotprod.inc for SDOT/UDOT's by-element form). SM3/SM4 are a
; Chinese national cryptography standard essentially never implemented
; outside hardware targeting that market, so this was judged not worth
; building new parsing infrastructure for; SM3SS1/SM3PARTW1/SM3PARTW2
; (plain register operands, no indexing) are still included below.
;
; Encodings verified instruction-by-instruction against `as -arch arm64` /
; `otool -t` (Apple's integrated assembler, `-march=armv8.6-a+sha3+sm4`).

; --- SHA-512 (3-register SHA512H/H2 take Q registers for the first two
; operands, per the architecture - not a typo) ---

macro sha512h a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_qn) & (@op1.type and @type_qn) & (@op2.type = @type_vn_2d)
	dd 0xce608000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro sha512h2 a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_qn) & (@op1.type and @type_qn) & (@op2.type = @type_vn_2d)
	dd 0xce608400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro sha512su0 a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type = @type_vn_2d) & (@op1.type = @type_vn_2d)
	dd 0xcec08000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro sha512su1 a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type = @type_vn_2d) & (@op1.type = @type_vn_2d) & (@op2.type = @type_vn_2d)
	dd 0xce608800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

; --- SHA-3 (EOR3/BCAX are 4-register 16B logical ops; RAX1/XAR are 2D) ---

macro eor3 a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type = @type_vn_16b) & (@op1.type = @type_vn_16b) & (@op2.type = @type_vn_16b) & (@op3.type = @type_vn_16b)
	dd 0xce000000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro bcax a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type = @type_vn_16b) & (@op1.type = @type_vn_16b) & (@op2.type = @type_vn_16b) & (@op3.type = @type_vn_16b)
	dd 0xce200000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro rax1 a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type = @type_vn_2d) & (@op1.type = @type_vn_2d) & (@op2.type = @type_vn_2d)
	dd 0xce608c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro xar a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type = @type_vn_2d) & (@op1.type = @type_vn_2d) & (@op2.type = @type_vn_2d) & (@op3.type and @type_immr_immc)
	aarch64.restrict @op3.data, 0, 63
	dd 0xce800000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

; --- SM3 (partial - see note above) ---

macro sm3ss1 a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_4s) & (@op2.type = @type_vn_4s) & (@op3.type = @type_vn_4s)
	dd 0xce400000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro sm3partw1 a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_4s) & (@op2.type = @type_vn_4s)
	dd 0xce60c000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro sm3partw2 a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_4s) & (@op2.type = @type_vn_4s)
	dd 0xce60c400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

; --- SM4 ---

macro sm4e a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_4s)
	dd 0xcec08400 + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro sm4ekey a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_4s) & (@op2.type = @type_vn_4s)
	dd 0xce60c800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro
