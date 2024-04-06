SECTIONS
{
    . = 0x7e00; /* Set the starting address of the kernel */

    /* Adjust the location of the kernel signature to match the bootloader */
    .kernel_signature :
    {
        /* Include kernel signature */
        *(.kernel_signature)
    } > 0x7c00 /* Load the kernel signature at the location expected by the bootloader */

    .text :
    {
        /* Section for executable code */
        *(.text) /* Include all text sections */
    }

    .data :
    {
        /* Section for initialized data */
        *(.data) /* Include all data sections */
    }

    .bss :
    {
        /* Section for uninitialized data */
        *(.bss) /* Include all BSS sections */
    }

    / DISCARD /:
    {
        /* Discard any sections that are not needed */
        *(*) /* Discard all other sections */
    }
}
