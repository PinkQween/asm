__attribute__((section(".kernel_signature"))) unsigned char kernel_signature[] = {0xDE, 0xAD, 0xBE, 0xEF};

#include <stddef.h>

void print_char(char c, int row, int col)
{
    volatile unsigned char *video_memory = (volatile unsigned char *)0xb8000;
    int offset = (row * 80 + col) * 2;
    video_memory[offset] = c;
    video_memory[offset + 1] = 0x0F; // Assuming white text on black background
}

void print_string(const char *str, int row, int col)
{
    while (*str)
    {
        print_char(*str++, row, col++);
    }
}

void kernel_main()
{
    // Print a message to indicate kernel initialization
    print_string("Kernel initialized!\n", 0, 0);

    // Infinite loop to keep the kernel running
    while (1)
    {
        // Add your kernel functionality here
    }
}
