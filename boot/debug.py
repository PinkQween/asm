import elftools.elf.elffile as elf

# Path to the kernel ELF file
elf_file_path = 'build/kernel.o'

# Open the ELF file
with open(elf_file_path, 'rb') as f:
    # Parse the ELF file
    elf_file = elf.ELFFile(f)
    
    # Get the section containing the kernel signature
    signature_section = elf_file.get_section_by_name('.kernel_signature')
    
    if signature_section:
        # Read the kernel signature data
        signature_data = signature_section.data()
        
        # Convert the signature data to a hexadecimal string
        signature_hex = ''.join(format(byte, '02x') for byte in signature_data)
        
        # Print the kernel signature
        print("Kernel Signature:", signature_hex)
    else:
        print("Kernel signature section not found in the ELF file.")
