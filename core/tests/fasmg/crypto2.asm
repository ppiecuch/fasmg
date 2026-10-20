; Companion to ../ref/crypto2.s - same instructions, same order.
; verify_encodings.sh diffs the two assembled outputs word for word.

format binary

include '../../../packages/aarch64/iset/aarch64.inc'

    sha512h   q0, q1, v2.2d
    sha512h2  q0, q1, v2.2d
    sha512su0 v0.2d, v1.2d
    sha512su1 v0.2d, v1.2d, v2.2d
    eor3      v0.16b, v1.16b, v2.16b, v3.16b
    rax1      v0.2d, v1.2d, v2.2d
    xar       v0.2d, v1.2d, v2.2d, 5
    bcax      v0.16b, v1.16b, v2.16b, v3.16b
    sm3ss1    v0.4s, v1.4s, v2.4s, v3.4s
    sm3partw1 v0.4s, v1.4s, v2.4s
    sm3partw2 v0.4s, v1.4s, v2.4s
    sm4e      v0.4s, v1.4s
    sm4ekey   v0.4s, v1.4s, v2.4s
    sha512h   q5, q6, v7.2d
    sha512h2  q5, q6, v7.2d
    sha512su0 v5.2d, v6.2d
    sha512su1 v5.2d, v6.2d, v7.2d
    eor3      v5.16b, v6.16b, v7.16b, v8.16b
    rax1      v5.2d, v6.2d, v7.2d
    xar       v5.2d, v6.2d, v7.2d, 20
    xar       v0.2d, v1.2d, v2.2d, 1
    bcax      v5.16b, v6.16b, v7.16b, v8.16b
    sm3ss1    v5.4s, v6.4s, v7.4s, v8.4s
    sm3partw1 v5.4s, v6.4s, v7.4s
    sm3partw2 v5.4s, v6.4s, v7.4s
    sm4e      v5.4s, v6.4s
    sm4ekey   v5.4s, v6.4s, v7.4s
    usdot     v0.4s, v1.16b, v2.16b
    usdot     v5.4s, v6.16b, v7.16b
    usdot     v0.2s, v1.8b, v2.8b
    bfdot     v0.4s, v1.8h, v2.8h
    bfdot     v5.4s, v6.8h, v7.8h
    bfdot     v0.2s, v1.4h, v2.4h
    bfmmla    v0.4s, v1.8h, v2.8h
    ret
