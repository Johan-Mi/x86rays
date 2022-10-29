section .rodata
ppm_header: db "P6 ", stringify(eval(image_width)), " ", stringify(eval(image_height)), ` 255\n`
ppm_header_len equ $-ppm_header

section .bss
image_buffer: resb image_width * image_height * 3
image_buffer_len equ $-image_buffer
align 4
t_min: resd 1
t_max: resd 1

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
    push rbx
    lea rbx, [image_buffer]
    push qword image_width * image_height - 1
.loop:
    mov rdi, [rsp]
    call color_at_index
    mov rdi, [rsp]
    lea rdi, [rdi*3]
    add rdi, rbx
    stosb
    shr eax, 8
    stosb
    shr eax, 8
    stosb
    dec qword [rsp]
    jns .loop
    add rsp, 8
    pop rbx
    ret

color_at_index: ; little endian RGB
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
    mov eax, image_height / 2
    cvtsi2ss xmm2, eax
    movsldup xmm2, xmm2
    divps xmm1, xmm2
    vbroadcastss xmm2, [.tan_vfov]
    mulps xmm1, xmm2
    insertps xmm1, [.f1], 0b00100000
    movaps xmm0, [camera_position]
    call color_at_ray
    jmp gamma_correct
align 4
.tan_vfov: dd tan_vfov
.f1: dd 1.0

color_at_ray:
    mov eax, [near_plane]
    mov [t_min], eax
    mov eax, [far_plane]
    mov [t_max], eax
    movaps xmm2, [.sphere]
    call hit_sphere
    movaps xmm0, [.blue]
    test al, al
    jz .no_hit
    movaps xmm0, [.red]
.no_hit:
    ret
align 16
.sphere: dd 0.0, 0.0, 5.0, 1.0
.blue: dd 0.5, 0.7, 1.0, 0.0
.red: dd 1.0, 0.0, 0.0, 0.0
