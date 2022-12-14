section .rodata
ppm_header: db "P6 ", stringify(eval(image_width)), " ", stringify(eval(image_height)), ` 255\n`
ppm_header_len equ $-ppm_header

section .bss
image_buffer: resb image_width * image_height * 3
image_buffer_len equ $-image_buffer
hit_front_face: resb 1
alignb 4
t_min: resd 1
t_max: resd 1
hit_index: resd 1
alignb 16
hit_position: resd 4
hit_normal: resd 4

section .text
write_image:
    mov eax, SYS_OPEN
    lea rdi, [image_file_path]
    mov esi, O_CREAT | O_WRONLY | O_TRUNC
    mov edx, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH ; -rw-r--r--
    syscall
    mov edi, eax
    mov eax, SYS_WRITE
    lea rsi, [ppm_header]
    mov rdx, ppm_header_len
    syscall
    mov eax, SYS_WRITE
    lea rsi, [image_buffer]
    mov rdx, image_buffer_len
    syscall
    ret

render_image:
    sub rsp, 8
    push rbx
    push rbp
    lea rbx, [image_buffer]
    mov ebp, image_width * image_height - 1
.loop:
    mov edi, ebp
    call color_at_index
    lea edi, [rbp*3]
    add rdi, rbx
    stosb
    shr eax, 8
    stosb
    shr eax, 8
    stosb
    dec ebp
    jns .loop
    pop rbp
    pop rbx
    add rsp, 8
    ret

color_at_index: ; little endian RGB
    push rbx
    mov eax, edi
    xor edx, edx
    mov esi, image_width
    div esi
    sub eax, image_height / 2
    sub edx, image_width / 2
    neg eax
    cvtsi2ss xmm1, eax
    psllq xmm1, 32
    cvtsi2ss xmm1, edx
    push qword 0
    push qword 0
    sub rsp, 16
    movaps [rsp], xmm1
    mov ebx, samples_per_pixel
.more_samples:
    call random_qwords
    vbroadcastss xmm3, [.mantissa_mask]
    vbroadcastss xmm4, [.f1]
    movaps xmm0, [camera_position]
    movaps xmm1, [rsp]
    movq xmm2, rax
    psrlq xmm2, 3
    pand xmm2, xmm3
    por xmm2, xmm4
    subps xmm2, xmm4
    addps xmm1, xmm2
    mov edi, image_height / 2
    cvtsi2ss xmm2, edi
    movsldup xmm2, xmm2
    divps xmm1, xmm2
    vbroadcastss xmm2, [.tan_vfov]
    mulps xmm1, xmm2
    insertps xmm1, [.f1], 0b00100000
    call color_at_ray
    movaps xmm1, [rsp+16]
    addps xmm1, xmm0
    movaps [rsp+16], xmm1
    dec ebx
    jnz .more_samples
    mov eax, samples_per_pixel
    cvtsi2ss xmm1, eax
    vbroadcastss xmm1, xmm1
    movaps xmm0, [rsp+16]
    divps xmm0, xmm1
    add rsp, 32
    pop rbx
    jmp gamma_correct
align 4
.tan_vfov: dd tan_vfov
.f1: dd 1.0
.mantissa_mask: dd (1 << 23) - 1

color_at_ray:
    push rbx
    push rbp
    mov rbx, max_depth
    sub rsp, 24
    movaps xmm2, [sky_color]
    movaps [rsp], xmm2
    mov eax, [near_plane]
    mov [t_min], eax
.loop:
    mov dword [hit_index], 0
    mov eax, [far_plane]
    mov [t_max], eax
    mov rbp, materials-scene-32
.more_shapes:
    lea rdi, [scene]
    lea rcx, [shape_pointers]
    movaps xmm2, [rdi+rbp+16]
    mov rsi, [rdi+rbp]
    mov edi, [rdi+rbp+8]
    inc edi
    call [rcx+rsi*8]
    sub rbp, 32
    jns .more_shapes
    dec dword [hit_index]
    js .no_hit
    xorps xmm3, xmm3
    vdpps xmm2, xmm1, [hit_normal], 0b01110001
    comiss xmm2, xmm3
    setb [hit_front_face]
    jb .hit_front_face
    ; Ensure that hit normal points outward
    vbroadcastss xmm2, [.sign_bit]
    xorps xmm2, [hit_normal]
    movaps [hit_normal], xmm2
.hit_front_face:
    lea rdi, [materials]
    mov eax, [hit_index]
    lea rsi, [material_pointers]
    shl eax, 2
    movaps xmm2, [rdi+rax*8+16]
    vmulps xmm3, xmm2, [rsp]
    movaps [rsp], xmm3
    mov rdi, [rdi+rax*8]
    call [rsi+rdi*8]
    movaps xmm1, xmm0
    movaps xmm0, [hit_position]
    dec rbx
    jnz .loop
    mov qword [rsp], 0
    mov qword [rsp+8], 0
.no_hit:
    movaps xmm0, [rsp]
    add rsp, 24
    pop rbp
    pop rbx
    ret
align 4
.sign_bit: dd 1 << 31
