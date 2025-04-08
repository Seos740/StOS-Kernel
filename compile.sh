#!/bin/bash

# Clean up old binary files
echo "Cleaning up old binaries..."
find . -type f -name "*.bin" -exec rm -f {} \;
find . -type f -name "*.o" -exec rm -f {} \;  # Remove object files too

# Loop over all ASM files
find . -type f -name "*.asm" | while read asm_file; do
    echo "Processing $asm_file..."

    # Check if the file contains the [org] directive (bare-metal)
    if grep -q '\[org\]' "$asm_file"; then
        # If [org] is found, use bin format (bare-metal)
        echo "Detected [org]. Using bin format for $asm_file."
        nasm -f bin -o "${asm_file}.bin" "$asm_file"
    
    # Otherwise, check if the file contains external references (extern keyword)
    elif grep -q 'extern' "$asm_file"; then
        # If 'extern' is found, use elf64 format
        echo "Detected external references. Using elf64 format for $asm_file."
        nasm -f elf64 -o "${asm_file}.o" "$asm_file"
    else
        # Default to bin format if no [org] or extern is found
        echo "No external references detected. Using bin format for $asm_file."
        nasm -f bin -o "${asm_file}.bin" "$asm_file"
    fi
done

echo "Compilation complete."

