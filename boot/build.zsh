nasm -o build/os.bin src/main.asm
qemu-system-x86_64 build/os.bin