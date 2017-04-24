#!/bin/bash

    nasm -f elf "$1".asm -o "$1".o
    ld -m elf_i386 -o "$1".exe io.o "$1".o
    echo "Proceso terminado"

