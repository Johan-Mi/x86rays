AS := nasm
ASFLAGS := -felf64 -g
LDFLAGS := -nostdlib -g

all: main

main.o: constants.s macros.s options.s image.s

%: %.s

clean:
	$(RM) main *.o image.ppm
.PHONY: clean
