# ECOAR
Project created for Computer Architecture classes at Warsaw University of Technology.
### Short description
The task was to create a program in C and assembly for 32-bit linux system that accepts binary file containing commands and create a drawing in bmp format based on it. Drawing method is the same as for turtle graphics.
#### To run:
make -f makefile
./turtle

### Details
Write a program containing two source files: main program written in C and assembly module callable from C. The C declaration of an assembly routine is given for each project task. Use NASM assembler (nasm.sf.net) to assemble the assembly module. Use C compiler driver to compile C module and link it with the output of assembler. The C program should use command line arguments to supply the parameters to an assembly routine and perform all I/O operations. No system functions nor C library functions should be called from assembly code. Arguments for bit manipulation routines should be entered in hexadecimal.
Routines processing .BMP files may receive as arguments either the pointer to the whole .BMP file image in memory or the pointer to bitmap and its sizes read by main program. The routines should correctly process images of any sizes unless stated otherwise.
