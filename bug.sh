#!/bin/bash
    
    #-*-ENCODING: UTF-8-*-
    nasm -g -f elf $1.asm
    ld -g -o $1.exe $1.o io.o -m elf_i386
    
    echo "Debugger listo"

