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
camera_position:
    camera_x: dd 0.0
    camera_y: dd 0.0
    camera_z: dd 0.0
    dd 0
