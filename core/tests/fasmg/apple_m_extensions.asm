; Companion to ../ref/apple_m_extensions.s - same instructions, same order.
; verify.sh diffs the two assembled outputs word for word.

format binary

include '../../../packages/aarch64/iset/aarch64.inc'

    ; --- LSE atomics (ARMv8.1) ---
    ldadd  w0, w1, [x2]
    ldadd  x0, x1, [x2]
    ldaddb w0, w1, [x2]
    ldaddh w0, w1, [x2]
    ldadda  w0, w1, [x2]
    ldaddl  w0, w1, [x2]
    ldaddal w0, w1, [x2]
    ldclr  w0, w1, [x2]
    ldeor  w0, w1, [x2]
    ldset  w0, w1, [x2]
    ldsmax w0, w1, [x2]
    ldsmin w0, w1, [x2]
    ldumax w0, w1, [x2]
    ldumin w0, w1, [x2]
    stadd  w1, [x2]
    staddl w1, [x2]
    swp    w0, w1, [x2]
    swpa   w0, w1, [x2]
    swpl   w0, w1, [x2]
    swpal  w0, w1, [x2]
    swpb   w0, w1, [x2]
    cas    w0, w1, [x2]
    casa   w0, w1, [x2]
    casl   w0, w1, [x2]
    casal  w0, w1, [x2]
    casb   w0, w1, [x2]
    cash   w0, w1, [x2]
    ldaddab  w0, w1, [x2]
    ldaddalb w0, w1, [x2]
    ldaddlb  w0, w1, [x2]
    ldaddah  w0, w1, [x2]
    ldclrab  w0, w1, [x2]
    ldumaxah w0, w1, [x2]
    stclr    w1, [x2]
    stclrl   w1, [x2]
    stclrb   w1, [x2]
    stclrlh  w1, [x2]
    swpab    w0, w1, [x2]
    swpalh   w0, w1, [x2]
    cas      x0, x1, [x2]
    casab    w0, w1, [x2]
    caslb    w0, w1, [x2]
    casalb   w0, w1, [x2]
    casah    w0, w1, [x2]

    ; --- BTI (ARMv8.5) ---
    bti
    bti c
    bti j
    bti jc

    ; --- Pointer authentication (ARMv8.3) ---
    pacia  x0, x1
    pacib  x0, x1
    pacda  x0, x1
    pacdb  x0, x1
    pacia1716
    pacib1716
    autia  x0, x1
    autib  x0, x1
    autda  x0, x1
    autdb  x0, x1
    autia1716
    autib1716
    paciza x0
    pacizb x0
    pacdza x0
    pacdzb x0
    autiza x0
    autizb x0
    autdza x0
    autdzb x0
    xpaci  x0
    xpacd  x0
    pacibsp
    paciasp
    pacibz
    paciaz
    autibsp
    autiasp
    autibz
    autiaz
    xpaclri
    retaa
    retab
    braa   x0, x1
    brab   x0, x1
    braaz  x0
    brabz  x0
    blraa  x0, x1
    blrab  x0, x1
    blraaz x0
    blrabz x0
    braa   x5, x3
    brab   x5, x3
    blraa  x5, x3
    blrab  x5, x3
    braaz  x5
    brabz  x5
    blraaz x5
    blrabz x5
    pacia  x7, x9
    paciza x7

    ; --- RNG (FEAT_RNG) ---
    mrs x0, rndr
    mrs x0, rndrrs
    mrs x3, rndr

    ; --- Dot product (ARMv8.2), vector form ---
    sdot v0.4s, v1.16b, v2.16b
    udot v0.4s, v1.16b, v2.16b
    sdot v0.2s, v1.8b, v2.8b
    udot v0.2s, v1.8b, v2.8b
    sdot v5.4s, v6.16b, v7.16b

    ret
