sphere equ 0

lambertian equ 0
metal equ 1
dielectric equ 2

section .bss
align 8
shape_pointers: resq 1
material_pointers: resq 3

section .text
set_up_scene:
    lea rax, [hit_sphere]
    mov [shape_pointers+sphere*8], rax
    lea rax, [scatter_lambertian]
    mov [material_pointers+lambertian*8], rax
    lea rax, [scatter_metal]
    mov [material_pointers+metal*8], rax
    lea rax, [scatter_dielectric]
    mov [material_pointers+dielectric*8], rax
    ret
