image_width equ 480
image_height equ 360
tan_vfov equ __?float32?__(0.577)
max_depth equ 50
samples_per_pixel equ 50

section .rodata
image_file_path: db "image.ppm", 0
align 4
near_plane: dd 0.001
far_plane: dd __?Infinity?__
gamma: dd 2.2
align 16
sky_color: dd 0.5, 0.7, 1.0, 0.0
camera_position:
    camera_x: dd 0.0
    camera_y: dd 0.0
    camera_z: dd 0.0
    dd 0
scene:
    dq sphere, 0
    dd 0.0, 0.0, 5.0, 1.0
    dq sphere, 1
    dd -2.0, -0.25, 4.0, 0.75
    dq sphere, 2
    dd 2.0, -0.25, 4.0, 0.75
    dq sphere, 3
    dd 0.0, -101.0, 0.0, 100.0
materials:
    dq dielectric, 0
    dd 1.0, 1.0, 1.0, 1.5
    dq metal, 0
    dd 1.0, 0.3, 0.3, 0.0
    dq lambertian, 0
    dd 0.05, 0.05, 1.0, 0.0
    dq lambertian, 0
    dd 0.05, 1.0, 0.05, 0.0
