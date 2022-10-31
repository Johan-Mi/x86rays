gamma_correct:
    ; TODO: Actually perform gamma correction instead of just naïvely clamping
    ; each channel
    ;
    ; Clamp each component between 0 and 1
    pxor xmm1, xmm1
    maxps xmm0, xmm1
    vbroadcastss xmm1, [.f1]
    minps xmm0, xmm1
    ; Scale up to 0-255
    vbroadcastss xmm1, [.f255]
    mulps xmm0, xmm1
    cvtps2dq xmm0, xmm0
    ; Pack lowest byte of each channel into a 32-bit integer
    pshufb xmm0, [.shuffle]
    movd eax, xmm0
    ret
.f1: dd 1.0
.f255: dd 255.0
align 16
.shuffle: dq 0x8080808080080400, 0x8080808080808080

log2ps:
    vpsrld xmm1, xmm0, 23
    vpbroadcastd xmm2, [.exponent_bias]
    psubd xmm1, xmm2
    pslld xmm0, 9
    psrld xmm0, 9
    vpbroadcastd xmm2, [.leading_one]
    por xmm0, xmm2
    cvtdq2ps xmm0, xmm0
    cvtdq2ps xmm1, xmm1
    mulps xmm0, xmm1
    vbroadcastss xmm1, [.mantissa_scale]
    divps xmm0, xmm1
    ret
align 4
.exponent_bias: dd 127
.leading_one: dd 1 << 24
.mantissa_scale: dd eval(1 << 24) %+ .0

fexp2:
    fstcw [rsp-2]
    or word [rsp-2], 0b11 << 10 ; Round towards zero
    fldcw [rsp-2]
    fld st0
    fld st0
    frndint
    fsubp
    f2xm1
    fld1
    faddp
    fscale
    fstp st1
    ret
