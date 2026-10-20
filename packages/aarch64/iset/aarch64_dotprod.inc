
; ARMv8.2 Dot Product (FEAT_DotProd) - SDOT/UDOT, vector form.
;
; Supported by every Apple M-series NEON unit. Each lane does 4-way INT8
; multiply-accumulate into an INT32 result - the building block ML/DSP
; kernels use for quantized inference and similar workloads.
;
; Only the vector (non-indexed) form is implemented: `sdot Vd.4s, Vn.16b,
; Vm.16b` / `sdot Vd.2s, Vn.8b, Vm.8b` (and udot). The "by element" form
; (`sdot Vd.4s, Vn.16b, Vm.4b[index]`) needs operand parsing for a `[index]`
; suffix that doesn't exist anywhere in this iset yet, so it's left as a
; follow-up rather than bolted on half-tested.
;
; Encoding verified instruction-by-instruction against `as -arch arm64` /
; `otool -t`.

iterate <instr, u>, sdot,0, udot,1

    macro instr Vd*, Vn*, Vm*
	aarch64.parse_operand @op0, Vd
	aarch64.parse_operand @op1, Vn
	aarch64.parse_operand @op2, Vm
	if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_16b) & (@op2.type = @type_vn_16b)
	    dd 0x0E809400 + (1 shl 30) + (u shl 29) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
	else if (@op0.type = @type_vn_2s) & (@op1.type = @type_vn_8b) & (@op2.type = @type_vn_8b)
	    dd 0x0E809400 + (u shl 29) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
	else
	    err 'invalid operand'
	end if
    end macro

end iterate

; ARMv8.6 mixed-sign dot product (FEAT_I8MM) and bfloat16 dot
; product/matrix-multiply (FEAT_BF16). Not verified present on any
; particular Apple Silicon generation - see the RNDR lesson in
; aarch64_sy.inc for why that distinction matters; these are newer/optional
; extensions than the base SDOT/UDOT above.

macro usdot Vd*, Vn*, Vm*
    aarch64.parse_operand @op0, Vd
    aarch64.parse_operand @op1, Vn
    aarch64.parse_operand @op2, Vm
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_16b) & (@op2.type = @type_vn_16b)
	dd 0x0E809C00 + (1 shl 30) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type = @type_vn_2s) & (@op1.type = @type_vn_8b) & (@op2.type = @type_vn_8b)
	dd 0x0E809C00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro bfdot Vd*, Vn*, Vm*
    aarch64.parse_operand @op0, Vd
    aarch64.parse_operand @op1, Vn
    aarch64.parse_operand @op2, Vm
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_8h) & (@op2.type = @type_vn_8h)
	dd 0x2E40FC00 + (1 shl 30) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type = @type_vn_2s) & (@op1.type = @type_vn_4h) & (@op2.type = @type_vn_4h)
	dd 0x2E40FC00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro

macro bfmmla Vd*, Vn*, Vm*
    aarch64.parse_operand @op0, Vd
    aarch64.parse_operand @op1, Vn
    aarch64.parse_operand @op2, Vm
    if (@op0.type = @type_vn_4s) & (@op1.type = @type_vn_8h) & (@op2.type = @type_vn_8h)
	dd 0x6E40EC00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
	err 'invalid operand'
    end if
end macro
