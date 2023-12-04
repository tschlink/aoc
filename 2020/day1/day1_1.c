#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
    char buff[20];
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    long fuel = 0;

    FILE * f = fopen("input1.txt", "r");
    if(f == NULL) {
        printf("Failed to open file.\n");
        exit(1);
    }

    while((read = getline(&line, &len, f)) != -1) {
        int cf = atoi(line) / 3 - 2;
        while(cf > 0) {
            fuel += cf;
            cf = cf / 3 - 2;
        }
    }
    printf("%ld", fuel);
    if(line) free(line);
    fclose(f);
    return 0;
}
