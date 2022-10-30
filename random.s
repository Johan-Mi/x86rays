section .text
random_unit_vector:
.loop:
    ; Randomize each axis between -1 and 1
    call random_qword
    push rax
    call random_qword
    movq xmm0, rax
    pop rax
    pinsrq xmm0, rax, 1
    psrlq xmm0, 3
    vbroadcastss xmm1, [.mantissa_mask]
    pand xmm0, xmm1
    vbroadcastss xmm1, [.exponent]
    por xmm0, xmm1
    vbroadcastss xmm1, [.f3]
    subps xmm0, xmm1
    ; Repeat until result is within the unit sphere
    dpps xmm1, xmm0, 0b01110001
    movss xmm2, [.f1]
    comiss xmm1, xmm2
    ja .loop
    ; Normalize
    sqrtss xmm1, xmm1
    vbroadcastss xmm1, xmm1
    divps xmm0, xmm1
    ret
align 4
.f1: dd 1.0
.f3: dd 2.0
.mantissa_mask: dd (1 << 23) - 1
.exponent: dd 0x40000000

random_qword:
    ; Uses the xoshiro256+ algorithm. Lowest 3 bits have low randomness.
    mov rax, [.state]
    xor [.state+16], rax
    add rax, [.state+24]
    mov rdx, [.state+8]
    xor [.state+24], rdx
    shl rdx, 17
    mov rdi, [.state+16]
    xor [.state+8], rdi
    mov rdi, [.state+24]
    xor [.state], rdi
    xor [.state+16], rdx
    rol qword [.state+24], 45
    ret
section .data
align 8
; Initial seed chosen at random
.state: dq 0x18f29013f53aa006, 0x93acb25bc2dfe126, 0x6536318c76c9c35d, 0x8a429541e4a02f14
