hit_sphere:
    xor eax, eax
    vsubps xmm3, xmm0, xmm2
    vdpps xmm4, xmm3, xmm1, 0b01110001
    xorps xmm4, [.flip_low_sign] ; half-b
    vmulss xmm6, xmm4, xmm4
    dpps xmm3, xmm3, 0b01110001
    vdpps xmm5, xmm2, xmm2, 0b10000001
    subss xmm3, xmm5
    vdpps xmm5, xmm1, xmm1, 0b01110001 ; a
    vfnmadd231ss xmm6, xmm3, xmm5 ; discriminant
    comiss xmm6, [.f0]
    jb .done ; no intersection
    sqrtss xmm7, xmm6
    vsubss xmm3, xmm4, xmm7
    divss xmm3, xmm5 ; root
    comiss xmm3, [t_min]
    jb .recalculate_root ; intersection out of range
    comiss xmm3, [t_max]
    jb .valid_intersection
.recalculate_root:
    vaddss xmm3, xmm4, xmm7
    divss xmm3, xmm5 ; root
    comiss xmm3, [t_min]
    jb .done ; intersection out of range
    comiss xmm3, [t_max]
    ja .done ; intersection out of range
.valid_intersection:
    mov eax, 1
    movss [t_max], xmm3
    vbroadcastss xmm3, xmm3
    vfmadd231ps xmm0, xmm1, xmm3 ; hit position
    vsubps xmm1, xmm0, xmm2
    pshufd xmm2, xmm2, 0b11111111
    divps xmm1, xmm2 ; hit normal
.done:
    ret
align 16
.flip_low_sign: dd 1 << 31
.f0: dd 0, 0, 0
