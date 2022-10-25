section .rodata
ppm_header: db "P6 ", stringify(eval(image_width)), " ", stringify(eval(image_height)), ` 255\n`
ppm_header_len equ $-ppm_header

section .bss
image_buffer: resb image_width * image_height * 3
image_buffer_len equ $-image_buffer

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
    cvtsi2ss xmm0, eax
    psllq xmm0, 32
    cvtsi2ss xmm0, edx
    mov eax, image_height
    cvtsi2ss xmm2, eax
    movsldup xmm2, xmm2
    divps xmm0, xmm2
    vbroadcastss xmm2, [.tan_vfov]
    mulps xmm0, xmm2
    vbroadcastss xmm1, [.f1]
    movq xmm1, xmm0
    movaps xmm0, [camera_position]
    call color_at_ray
    jmp gamma_correct
align 4
.tan_vfov: dd tan_vfov
.f1: dd __?float32?__(1.0)

color_at_ray:
    movaps xmm0, xmm1
    ret
