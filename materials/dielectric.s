scatter_dielectric:
    ; Normalize ray direction
    vdpps xmm3, xmm1, xmm1, 0b01110001
    sqrtss xmm3, xmm3
    vbroadcastss xmm3, xmm3
    divps xmm1, xmm3
    movss xmm3, [.f1]
    shufps xmm2, xmm2, 0b11111111 ; Refraction ratio
    test byte [hit_front_face], 1
    jnz .hit_front_face
    vdivss xmm2, xmm3, xmm2 ; Refraction ratio
    vbroadcastss xmm2, xmm2
.hit_front_face:
    movss xmm5, [.sign_bit]
    vdpps xmm4, xmm1, [hit_normal], 0b01110001
    xorps xmm4, xmm5 ; Cos theta
    minss xmm4, xmm3
    movaps xmm5, xmm4
    vfnmadd132ps xmm5, xmm3, xmm4
    sqrtss xmm5, xmm5 ; Sin theta
    mulss xmm5, xmm2
    comiss xmm5, xmm3
    jae .reflect
    vsubss xmm5, xmm3, xmm2
    vaddss xmm6, xmm3, xmm2
    divss xmm5, xmm6
    mulss xmm5, xmm5 ; R0
    vsubss xmm6, xmm3, xmm4
    vmulss xmm7, xmm6, xmm6
    mulss xmm7, xmm7
    mulss xmm7, xmm6
    vsubss xmm6, xmm3, xmm5
    vfmadd231ss xmm5, xmm6, xmm7
    call random_qwords
    shr eax, 9
    or eax, __?float32?__(1.0)
    movd xmm6, eax
    subss xmm6, xmm3
    comiss xmm5, xmm6
    jae .reflect
    ; Refract
    vbroadcastss xmm4, xmm4
    movss xmm5, [.not_sign_bit]
    vfmadd132ps xmm4, xmm1, [hit_normal]
    mulps xmm4, xmm2 ; Perpendicular
    vdpps xmm0, xmm4, xmm4, 0b01110001
    subss xmm0, xmm3
    andps xmm0, xmm5
    sqrtss xmm0, xmm0
    vbroadcastss xmm0, xmm0
    vfnmadd132ps xmm0, xmm4, [hit_normal]
    ret
.reflect:
    vdpps xmm0, xmm1, [hit_normal], 0b01110001
    mulss xmm0, [.fm2]
    vbroadcastss xmm0, xmm0
    vfmadd132ps xmm0, xmm1, [hit_normal]
    ret
align 4
.f1: dd 1.0
.fm2: dd -2.0
.sign_bit: dd 1 << 31
.not_sign_bit: dd ~(1 << 31)