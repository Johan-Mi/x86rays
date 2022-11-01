gamma_correct:
    ; Raise each channel to 1/gamma
    sub rsp, 24
    movaps [rsp], xmm0
    fld dword [rsp]
    call raise_to_inv_gamma
    fstp dword [rsp]
    fld dword [rsp+4]
    call raise_to_inv_gamma
    fstp dword [rsp+4]
    fld dword [rsp+8]
    call raise_to_inv_gamma
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

raise_to_inv_gamma:
    fld1
    fld dword [gamma]
    fdivp
    fxch
    fyl2x
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
