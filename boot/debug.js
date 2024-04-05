const fs = require('fs');
const elfy = require('elfy');

// Path to the kernel ELF file
const elfFilePath = 'build/kernel.o';

// Read the ELF file
fs.readFile(elfFilePath, (err, data) => {
    if (err) {
        console.error('Error reading ELF file:', err);
        return;
    }

    console.log(data);

    // Parse the ELF file
    const parsedElf = elfy.parse(data);

    // Find the section containing the kernel signature
    const signatureSection = parsedElf.sections.find(section => section.name === '.kernel_signature');
    if (signatureSection) {
        // Extract the kernel signature data
        const signatureData = data.slice(signatureSection.offset, signatureSection.offset + signatureSection.size);

        // Convert the signature data to a hexadecimal string
        const signatureHex = signatureData.toString('hex');

        // Print the kernel signature
        console.log('Kernel Signature:', signatureHex);
    } else {
        console.log('Kernel signature section not found in the ELF file.');
    }
});
