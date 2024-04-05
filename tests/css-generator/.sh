#!/bin/bash

# Assemble and run the assembly code to generate the random number
nasm -f elf32 random_css_generator.asm -o random_css_generator.o
ld -m elf_i386 -o random_css_generator random_css_generator.o
./random_css_generator > random.css

# Parse the output of the assembly code and update the CSS file
random_number=$(cat random.css | grep -oP '(?<=rgb\()\d+(?=\, \d+, \d+\))')
sed -i "s/background-color: rgb(0, 0, 0);/background-color: rgb($random_number);/g" random.css