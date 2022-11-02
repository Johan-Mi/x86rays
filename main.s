default rel

global _start

%include "constants.s"
%include "macros.s"
%include "options.s"
%include "image.s"
%include "color.s"
%include "random.s"
%include "shapes/sphere.s"
%include "materials/lambertian.s"
%include "materials/metal.s"
%include "materials/dielectric.s"

section .text
_start:
    call render_image
    call write_image
    mov eax, SYS_EXIT
    xor edi, edi
    syscall
