ENTRY(kernel_main)

SECTIONS {
    . = 0x100000; /* Set the starting address of the kernel */

    .kernel_signature : { /* Section for kernel signature */
        *(.kernel_signature) /* Include kernel signature */
    }

    .text : { /* Section for executable code */
        *(.text) /* Include all text sections */
    }

    .data : { /* Section for initialized data */
        *(.data) /* Include all data sections */
    }

    .bss : { /* Section for uninitialized data */
        *(.bss) /* Include all BSS sections */
    }

    /DISCARD/ : { /* Discard any sections that are not needed */
        *(*) /* Discard all other sections */
    }
}
