COMPILER = ~/opt/cross/bin/i686-cavos-gcc
CFLAGS = -std=gnu99 -ffreestanding -Wall -Wextra -L../../libs/system -I../../libs/system -lsystem
OUTPUT = testing.cav
TARGET = ../../../target/software/

all: clean compile install

compile:
	$(COMPILER) main.c utils.c -o $(OUTPUT) $(CFLAGS)

install:
	mkdir -p $(TARGET)
	cp $(OUTPUT) $(TARGET)

clean:
	rm -f $(OUTPUT)
