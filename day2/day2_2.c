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

void copyArray(int* input, int* out, int nb)
{
    int i = 0;
    while(i < nb)
    {
        *(out + i) = *(input + i);
        i++;
    }
}

int main(void) {
    char input[] = "1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,6,19,2,19,6,23,1,23,5,27,1,9,27,31,1,31,10,35,2,35,9,39,1,5,39,43,2,43,9,47,1,5,47,51,2,51,13,55,1,55,10,59,1,59,10,63,2,9,63,67,1,67,5,71,2,13,71,75,1,75,10,79,1,79,6,83,2,13,83,87,1,87,6,91,1,6,91,95,1,10,95,99,2,99,6,103,1,103,5,107,2,6,107,111,1,10,111,115,1,115,5,119,2,6,119,123,1,123,5,127,2,127,6,131,1,131,5,135,1,2,135,139,1,139,13,0,99,2,0,14,0"; //"1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,9,19,1,19,5,23,2,6,23,27,1,6,27,31,2,31,9,35,1,35,6,39,1,10,39,43,2,9,43,47,1,5,47,51,2,51,6,55,1,5,55,59,2,13,59,63,1,63,5,67,2,67,13,71,1,71,9,75,1,75,6,79,2,79,6,83,1,83,5,87,2,87,9,91,2,9,91,95,1,5,95,99,2,99,13,103,1,103,5,107,1,2,107,111,1,111,5,0,99,2,14,0,0";
    char **tokens;
    int orig_numbers[121];
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
        }
    }

    free(tokens);

    copyArray(numbers, orig_numbers, 121);
    int idx;

    int i, j;

    for(i = 0; i < 100; i++)
    {
        for(j = 0; j < 100; j++)
        {
            idx = 0;
            copyArray(orig_numbers, numbers, 121);
            numbers[1] = i;
            numbers[2] = j;

            for(;idx < 122;)
            {
                int opc = numbers[idx];
                if (opc == 99 && numbers[0] == 19690720)
                {
                    printf("The final values are: noun: %d, verb:%d\n", i, j);
                    printf("Result is %d\n", 100 * i + j);
                    exit(0);
                }

                int op1 = numbers[idx+1];
                int op2 = numbers[idx+2];
                int op3 = numbers[idx+3];

                if(opc == 1) numbers[op3] = numbers[op1] + numbers[op2];
                if(opc == 2) numbers[op3] = numbers[op1] * numbers[op2];

                idx += 4;
            }
        }
    }
    return 0;
}
