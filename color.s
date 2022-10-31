gamma_correct:
    ; Raise each channel to 1/gamma
    call log2ps
    vbroadcastss xmm1, [gamma]
    divps xmm0, xmm1
    sub rsp, 24
    movaps [rsp], xmm0
    fld dword [rsp]
    call fexp2
    fstp dword [rsp]
    fld dword [rsp+4]
    call fexp2
    fstp dword [rsp+4]
    fld dword [rsp+8]
    call fexp2
    fstp dword [rsp+8]
    movaps xmm0, [rsp]
    add rsp, 24
    vbroadcastss xmm4, [.f1]
    movss xmm5, [.f1]
    vdpps xmm1, xmm0, [.luma_coefficients], 0b01110111
    vsubps xmm3, xmm1, xmm0
    vsubps xmm2, xmm1, xmm4
    divps xmm2, xmm3
    vcmpgtps xmm3, xmm0, xmm4
    movd eax, xmm3
    test al, al
    jz .dont_clamp_r
    minss xmm5, xmm2
.dont_clamp_r:
    extractps eax, xmm3, 1
    test al, al
    jz .dont_clamp_g
    shufps xmm6, xmm2, 0b01010101
    minss xmm5, xmm6
.dont_clamp_g:
    extractps eax, xmm3, 2
    test al, al
    jz .dont_clamp_b
    shufps xmm6, xmm2, 0b10101010
    minss xmm5, xmm6
.dont_clamp_b:
    vbroadcastss xmm5, xmm5
    subps xmm0, xmm1
    mulps xmm0, xmm5
    addps xmm0, xmm1
    ; Clamp each channel between 0 and 1
    pxor xmm1, xmm1
    maxps xmm0, xmm1
    minps xmm0, xmm4
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
.luma_coefficients: dd 0.299, 0.587, 0.114, 0.0

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
