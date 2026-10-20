; ARMv8.2 dot-product (FEAT_DotProd, packages/aarch64/iset/aarch64_dotprod.inc):
; SDOT does 4-way INT8 multiply-accumulate into an INT32 lane, in one
; instruction - the building block quantized ML/DSP kernels use. Every
; Apple M-series NEON unit supports it.
;
; Computes the dot product of two 4-element int8 vectors, lane-replicated
; across all 16 bytes so a single SDOT produces the same INT32 result in
; each of the 4 output lanes.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

  start:
	adr	x0,bytes_a
	adr	x1,bytes_b
	ld1	{v0.16b},[x0]
	ld1	{v1.16b},[x1]

	movi	v2.4s,0			; accumulator starts at 0
	sdot	v2.4s,v0.16b,v1.16b

	adr	x2,result
	st1	{v2.4s},[x2]
	ldr	w3,[x2]

	; (1*10 + 2*20 + 3*30 + 4*40) = 10+40+90+160 = 300, repeated in each lane
	check	w3,300
	ldr	w3,[x2,4]
	check	w3,300

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 16

  test_messages

  ; four groups of 4 int8 values (same 4 values repeated), one group feeds
  ; each of the 4 output lanes
  bytes_a db 1,2,3,4, 1,2,3,4, 1,2,3,4, 1,2,3,4
  bytes_b db 10,20,30,40, 10,20,30,40, 10,20,30,40, 10,20,30,40
  result dd 0,0,0,0
