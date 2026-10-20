; Detecting the CPU model and its actual feature set via sysctlbyname -
; backed by the real `sysctl` syscall, this is the correct, documented way
; to find out what the hardware supports, in contrast to just trying an
; instruction and seeing whether it traps.
;
; That contrast isn't hypothetical - this session found out the hard way
; that `mrs x0, rndr` (FEAT_RNG) traps as an illegal instruction on this
; M1 (see PORTING.md). Asking `sysctl -a | grep hw.optional.arm` afterward
; confirmed there isn't even a `hw.optional.arm.FEAT_RNG` entry at all on
; this machine - sysctlbyname would have given the same answer safely,
; with no crash. It also turned up two features this session has opinions
; about: `FEAT_SHA3` is really present here (backing the SHA3/SM4 support
; added to aarch64_crypto2.inc), while `FEAT_I8MM`/`FEAT_BF16` are not
; (confirming the USDOT/BFDOT/BFMMLA added to aarch64_dotprod.inc, while
; correctly encoded, aren't backed by real hardware on this particular
; chip - exactly as documented there).
;
; int sysctlbyname(const char *name, void *oldp, size_t *oldlenp,
;                   void *newp, size_t newlen);
; returns 0 on success; oldp/oldlenp receive the value and its size.

include 'common.inc'

segment '__TEXT' readable executable notwritable

section '__text' flags(S_ATTR_PURE_INSTRUCTIONS+S_ATTR_SOME_INSTRUCTIONS) align 16

; int feature_flag(char *sysctl_name) -> the int value, or -1 if the query
; itself failed (e.g. the name doesn't exist on this OS/CPU at all)
feature_flag:
	stp	x29,x30,[sp,-32]!
	mov	x29,sp
	mov	x19,x0			; keep the name pointer across the call

	adr	x1,feature_buf
	adr	x2,feature_buf.size
	mov	x3,0
	mov	x4,0
	ccall	sysctlbyname,x19,x1,x2,x3,x4
	cmp	x0,0
	bne	feature_query_failed

	adr	x1,feature_buf
	ldr	w0,[x1]
	b	feature_flag_done
  feature_query_failed:
	mov	x0,-1
  feature_flag_done:
	ldp	x29,x30,[sp],32
	ret

  start:
	; print the actual CPU model string, purely for a human to look at -
	; its value isn't asserted, since it's expected to vary machine to
	; machine
	adr	x0,brand_name
	adr	x1,brand_buf
	adr	x2,brand_buf.size
	mov	x3,0
	mov	x4,0
	ccall	sysctlbyname,x0,x1,x2,x3,x4
	check	w0,0			; the query itself must succeed

	adr	x0,brand_buf
	ccall	printf,x0

	; FEAT_LSE is mandatory from ARMv8.1 - every Apple Silicon chip
	; implements it (see aarch64_lse.inc)
	adr	x0,feat_lse
	bl	feature_flag
	check	w0,1

	; confirmed present on this chip - backs aarch64_crypto2.inc's SHA3
	; instructions (EOR3/RAX1/XAR/BCAX)
	adr	x0,feat_sha3
	bl	feature_flag
	check	w0,1

	; confirmed *not* present on this chip - the ARMv8.6 mixed-precision
	; dot product aarch64_dotprod.inc added (USDOT) is correctly encoded
	; but has no hardware to actually run it here
	adr	x0,feat_i8mm
	bl	feature_flag
	check	w0,0

	; a nonexistent sysctl name: the query itself should fail (-1), not
	; return some default value
	adr	x0,bogus_name
	bl	feature_flag
	check	w0,-1

	pass

segment '__DATA' readable writable notexecutable

section '__data' align 8

  test_messages

  brand_name db 'machdep.cpu.brand_string',0
  feat_lse   db 'hw.optional.arm.FEAT_LSE',0
  feat_sha3  db 'hw.optional.arm.FEAT_SHA3',0
  feat_i8mm  db 'hw.optional.arm.FEAT_I8MM',0
  bogus_name db 'hw.optional.arm.FEAT_NOT_A_REAL_FEATURE',0

  align 8
  brand_buf rb 64
  brand_buf.size dq 64

  feature_buf dd 0
  feature_buf.size dq 4
