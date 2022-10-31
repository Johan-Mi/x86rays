scatter_lambertian:
    call random_unit_vector
    addps xmm0, [hit_normal]
    vdpps xmm1, xmm0, xmm0, 0b01110001
    ucomiss xmm1, [.too_close_to_zero]
    ja .done
    movaps xmm0, [hit_normal]
.done:
    ret
align 4
.too_close_to_zero: dd 3e-10
