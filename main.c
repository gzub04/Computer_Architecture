
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INSTRUCTIONS_FILE "input.bin"
#define OUTPUT_FILENAME "output.bmp"
// everything in bytes
#define BMP_FILE_SIZE 90122 // 600x50x3 + 122(header)
#define BYTES_PER_ROW 1800
#define BMP_NO_HEADER_SIZE 90000 // size without header
#define HEADER_SIZE 122

// reads file and outputs its size in bytes
int read_bin_file(unsigned char **instructions)
{
    FILE *bin_file;

    bin_file = fopen(INSTRUCTIONS_FILE, "rb");
    if (bin_file == NULL)
    {
        printf("There was a problem reading the file input.bin\n");
        return 0;
    }

    fseek(bin_file, 0L, SEEK_END);
    int f_size = ftell(bin_file);
    rewind(bin_file); // return to the beginning of the file

    *instructions = malloc(f_size);
    if (*instructions == NULL)
    {
        printf("There was a problem allocating memory for the binary file.\n");
        return 0;
    }

    fread(*instructions, f_size, 1, bin_file); // fread(buffer where it is saved, size of one element in bytes, num of elements, source)
    fclose(bin_file);

    return f_size;
}

// returns size of command in bytes
unsigned int size(unsigned short *instr_ptr)
{
    unsigned short instruction = *instr_ptr & 3;
    if (instruction == 3)
        return 4;
    else
        return 2;
}

int save_BMP(unsigned char *BMP_file)
{
    FILE *out_file;

    out_file = fopen(OUTPUT_FILENAME, "wb");
    if (out_file == NULL)
    {
        printf("Error creating output file.\n");
        return 1;
    }

    fwrite(BMP_file, 1, BMP_FILE_SIZE, out_file);
    fclose(out_file);

    return 0;
}

extern int turtle(unsigned char *dest_bitmap, unsigned char *commands, unsigned int commands_size);

int main()
{
    unsigned char *instructions; // will contain all of the instructions after read_bin_file

    int instr_number = read_bin_file(&instructions); // outputs size of instruction block in bytes
    if (instr_number == 0)
    {
        printf("No instructions found.\n");
        return 1;
    }

    // ================ Create BMP file ================

    // create header
    unsigned char *BMP_file = malloc(BMP_FILE_SIZE);
    unsigned char header[HEADER_SIZE] = {0x42, 0x4D, 0x0A, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7A, 0x00,
                                         0x00, 0x00, 0x6C, 0x00, 0x00, 0x00, 0x58, 0x02, 0x00, 0x00, 0x32, 0x00,
                                         0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x5F,
                                         0x01, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x00, 0x00,
                                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x42, 0x47, 0x52, 0x73, 0x00, 0x00,
                                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00,
                                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                         0x00, 0x00};
    memcpy(BMP_file, &header, 122);

    // fill bitmap with white colour
    unsigned int *tmp = (unsigned int *)(BMP_file + HEADER_SIZE);
    int count;
    for (count = 0; count < BMP_NO_HEADER_SIZE >> 2; count++, tmp++)
    {
        *tmp = 0xffffffff;
    }
    // =================================================

    int turtle_result = turtle(BMP_file, instructions, instr_number);

    // save to BMP file
    int ready_picture = save_BMP(BMP_file);

    free(BMP_file);
    free(instructions);
    if(turtle_result == 0)
    {
        printf("Program finished successfully.\n");
        return 0;
    }
    if(turtle_result == 1)
    {
        printf("Task failed successfully! Wrong X.\n");
        return 1;
    }
    if(turtle_result == 2)
    {
        printf("Task failed successfully! Wrong Y.\n");
        return 2;
    }
}