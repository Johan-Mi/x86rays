scatter_metal:
    vdpps xmm0, xmm1, [hit_normal], 0b01110001
    mulss xmm0, [.fm2]
    vbroadcastss xmm0, xmm0
    vfmadd132ps xmm0, xmm1, [hit_normal]
    ret
align 4
.fm2: dd -2.0
