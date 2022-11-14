gamma_correct:
    ; Raise each channel to 1/gamma
    fld1
    fld dword [gamma]
    fdivp
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
    fstp st0
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
    vpermilps xmm6, xmm2, 0b01010101
    minss xmm5, xmm6
.dont_clamp_g:
    extractps eax, xmm3, 2
    test al, al
    jz .dont_clamp_b
    vpermilps xmm6, xmm2, 0b10101010
    minss xmm5, xmm6
.dont_clamp_b:
    vbroadcastss xmm5, xmm5
    subps xmm0, xmm1
    vfmadd132ps xmm0, xmm1, xmm5
    ; Scale up each channel to 0-255, convert to integers and pack into a dword
    vbroadcastss xmm1, [.f255]
    mulps xmm0, xmm1
    cvtps2dq xmm0, xmm0
    packusdw xmm0, xmm0
    packuswb xmm0, xmm0
    movd eax, xmm0
    ret
.f1: dd 1.0
.f255: dd 255.0
align 16
.luma_coefficients: dd 0.299, 0.587, 0.114, 0.0

raise_to_inv_gamma:
    fld st1
    fxch
    fyl2x
    fld st0
    fld st0
    fisttp dword [rsp-4]
    fild dword [rsp-4]
    fsubp
    f2xm1
    fld1
    faddp
    fscale
    fstp st1
    ret
