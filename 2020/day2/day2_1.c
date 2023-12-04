#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

char** split(char *str, const char delim)
{
    char ** result = NULL;
    size_t count = 0;
    char *tmp = str;
    char *last_comma = NULL;
    char delimiter[2];
    delimiter[0] = delim;
    delimiter[1] = '\0'; //or just 0?

    // count number of elements with moving pointer
    while(*tmp)
    {
        if(delim == *tmp)
        {
            count++;
            last_comma = tmp;
        }
        tmp++;
    }

    // add space for trailing token (comparing addresses?)
    count++; // += last_comma < (str + strlen(str) - 1);

    // add space for terminating null string so caller knows where the list of returned strings ends.
    count++;

    result = malloc(sizeof(char*) * count);

    if(result)
    {
        size_t idx = 0;
        char *token = strtok(str, delimiter);
        while(token)
        {
            assert(idx < count);
            *(result+idx) = malloc(sizeof(char) * strlen(token));
            strcpy(*(result + idx), token);
            token = strtok(0, delimiter);
            idx++;
        }
        assert(idx == count - 1);
        *(result + idx) = 0;
    }

    return result;
}

int main(void) {
    char input[] = "1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,9,19,1,19,5,23,2,6,23,27,1,6,27,31,2,31,9,35,1,35,6,39,1,10,39,43,2,9,43,47,1,5,47,51,2,51,6,55,1,5,55,59,2,13,59,63,1,63,5,67,2,67,13,71,1,71,9,75,1,75,6,79,2,79,6,83,1,83,5,87,2,87,9,91,2,9,91,95,1,5,95,99,2,99,13,103,1,103,5,107,1,2,107,111,1,111,5,0,99,2,14,0,0";
    char **tokens;
    int numbers[121];

    tokens = split(input, ',');

    if(tokens)
    {
        int i;
        // it's still off by one
        for(i = 0; *(tokens + i); i++)
        {
            numbers[i] = atoi(*(tokens + i));
            free(*(tokens+i));
            printf("%d,", numbers[i]);
        }
        printf("\n");
    }

    free(tokens);

    int idx = 0;

    numbers[1] = 12;
    numbers[2] = 2;
    for(;;)
    {
        int opc = numbers[idx];
        if(opc != 1 && opc != 2 && opc != 99) { printf("Found unknown opcode %d at index %d\n", opc, idx); exit(1); }
        if (opc == 99)
        {
            printf("The final result is %d\n", numbers[0]);
            exit(0);
        }

        int op1 = numbers[idx+1];
        int op2 = numbers[idx+2];
        int op3 = numbers[idx+3];

        if(opc == 1) numbers[op3] = numbers[op1] + numbers[op2];
        if(opc == 2) numbers[op3] = numbers[op1] * numbers[op2];

        idx += 4;
    }

    return 0;
}
