AS := nasm
ASFLAGS := -felf64 -g
LDFLAGS := -nostdlib -g

all: main

main.o: $(shell find -name '*.s')

%: %.s

clean:
	$(RM) main *.o image.ppm
.PHONY: clean
