%define stringify(&x) x
%define eval(=x) x

%define todo _todo_impl __?FILE?__, stringify(__?LINE?__),
%macro _todo_impl 3
    [section .rodata]
%%message: db `\e[1\;31mTODO\e[0m: `, %1, ":", %2, ": ", %3, `\n`
%%endmessage:
    __?SECT?__
    mov eax, SYS_WRITE
    mov edi, STDOUT_FILENO
    lea rsi, [%%message]
    mov rdx, %%endmessage-%%message
    syscall
    mov eax, SYS_EXIT
    mov edi, 1
    syscall
%endmacro
