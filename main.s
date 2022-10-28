default rel

global _start

%include "constants.s"
%include "macros.s"
%include "options.s"
%include "image.s"
%include "color.s"
%include "shapes/sphere.s"

section .text
_start:
    call render_image
    call write_image
    mov eax, SYS_EXIT
    xor edi, edi
    syscall
