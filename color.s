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
.f1: dd __?float32?__(1.0)
.f255: dd __?float32?__(255.0)
align 16
.shuffle: dq 0x8080808080080400, 0x8080808080808080
