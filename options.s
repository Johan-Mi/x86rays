image_width equ 480
image_height equ 360
tan_vfov equ __?float32?__(0.577)

section .rodata
image_file_path: db "image.ppm", 0
align 16
camera_position:
    camera_x: dd __?float32?__(0.0)
    camera_y: dd __?float32?__(0.0)
    camera_z: dd __?float32?__(0.0)
    dd 0
