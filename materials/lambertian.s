scatter_lambertian:
    call random_unit_vector
    addps xmm0, [hit_normal]
    ; TODO: Replace directions that are too close to zero
    ret
