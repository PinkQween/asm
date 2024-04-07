#!/bin/bash

# Set the path to your cross-compiler toolchain
CROSS_COMPILER_PREFIX="i686-elf-"

echo "Compiling kernel..."
${CROSS_COMPILER_PREFIX}gcc -g -m32 -ffreestanding -c src/kernel/kernel.c -o build/kernel.o

echo "Building bootloader..."
nasm -f bin src/boot/bootloader.asm -o build/bootloader.bin

echo "Combining bootloader and kernel..."
cat build/bootloader.bin build/kernel.o > build/os.bin

echo "Done."

# Launch QEMU with debugging support
qemu-system-x86_64 -s -fda build/os.bin