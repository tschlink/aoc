#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define IASIZE(x) (sizeof(x) / sizeof(int))

size_t split(char *str, const char delim, char*** result)
{
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

    *result = malloc(sizeof(char*) * count);
    char **res = *result;

    if(res)
    {
        size_t idx = 0;
        char *token = strtok(str, delimiter);
        while(token)
        {
            assert(idx < count);
            *(res + idx) = malloc(sizeof(char) * strlen(token));
            strcpy(*(res + idx), token);
            token = strtok(0, delimiter);
            idx++;
        }
        assert(idx == count - 1);
        *(res + idx) = 0;
    }
    return count;
}

void copyArray(int* in, int* out, int nb)
{
    int i = 0;
    while(i < nb)
    {
        *(out + i) = *(in + i);
        i++;
    }
}

int compute(int input[], int length)
{
    int numbers[length];
    copyArray(input, numbers, length);
    int idx;

    idx = 0;

    while(idx < length)
    {
        int instr = numbers[idx];
        if (instr % 100 == 99) break;

        int opcode, param_mode, param_modes;
        opcode = instr % 10; //get last digit;
        param_mode = (instr % 100) / 10; //second to last digit
        param_modes = instr / 100; //get everything preceeding opcode

        int modes[3] = {0};
        if(param_mode == 1)
        {
            for(int i = 0; param_modes; i++)
            {
                modes[i] = param_modes % 10;
                param_modes /= 10;
            }
        }

        int op1, op2, op3, success;
        switch(opcode)
        {
            case 1:
            case 2:
                op1 = numbers[idx+1];
                op2 = numbers[idx+2];
                op3 = numbers[idx+3];

                if(opcode == 1) numbers[op3] = (modes[0] ? numbers[op1] : op1) + (modes[1] ? numbers[op2] : op2);
                if(opcode == 2) numbers[op3] = (modes[0] ? numbers[op1] : op1) * (modes[1] ? numbers[op2] : op2);
                idx += 4;
                break;
            case 3:
                op1 = 0;
                success = scanf("%d", &op1);
                printf("Read %d\n", op1);
                if(success) numbers[idx+1] = op1;
                else
                {
                    printf("Error while reading form stdin\n");
                    exit(1);
                }
                idx += 2;
                break;
            case 4: 
                op1 = numbers[idx+1];
                printf("%d\n", op1);
                idx += 2;
                break;
            default:
                    printf("Found unknown opcode at index %d\n", idx);
                    exit(1);
        }
    }
    return numbers[0];
}

int main(void) {
    int input[] = {3,225,1,225,6,6,1100,1,238,225,104,0,1102,57,23,224,101,-1311,224,224,4,224,1002,223,8,223,101,6,224,224,1,223,224,223,1102,57,67,225,102,67,150,224,1001,224,-2613,224,4,224,1002,223,8,223,101,5,224,224,1,224,223,223,2,179,213,224,1001,224,-469,224,4,224,102,8,223,223,101,7,224,224,1,223,224,223,1001,188,27,224,101,-119,224,224,4,224,1002,223,8,223,1001,224,7,224,1,223,224,223,1,184,218,224,1001,224,-155,224,4,224,1002,223,8,223,1001,224,7,224,1,224,223,223,1101,21,80,224,1001,224,-101,224,4,224,102,8,223,223,1001,224,1,224,1,224,223,223,1101,67,39,225,1101,89,68,225,101,69,35,224,1001,224,-126,224,4,224,1002,223,8,223,1001,224,1,224,1,224,223,223,1102,7,52,225,1102,18,90,225,1101,65,92,225,1002,153,78,224,101,-6942,224,224,4,224,102,8,223,223,101,6,224,224,1,223,224,223,1101,67,83,225,1102,31,65,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1007,226,226,224,102,2,223,223,1005,224,329,1001,223,1,223,108,677,226,224,1002,223,2,223,1005,224,344,1001,223,1,223,1007,677,677,224,1002,223,2,223,1005,224,359,1001,223,1,223,1107,677,226,224,102,2,223,223,1006,224,374,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,389,101,1,223,223,8,677,677,224,102,2,223,223,1006,224,404,1001,223,1,223,1008,226,226,224,102,2,223,223,1006,224,419,1001,223,1,223,107,677,226,224,102,2,223,223,1006,224,434,101,1,223,223,7,226,226,224,1002,223,2,223,1005,224,449,1001,223,1,223,1107,226,226,224,1002,223,2,223,1006,224,464,1001,223,1,223,1107,226,677,224,1002,223,2,223,1005,224,479,1001,223,1,223,8,677,226,224,1002,223,2,223,1006,224,494,1001,223,1,223,1108,226,677,224,1002,223,2,223,1006,224,509,101,1,223,223,1008,677,677,224,1002,223,2,223,1006,224,524,1001,223,1,223,1008,677,226,224,102,2,223,223,1006,224,539,1001,223,1,223,1108,677,677,224,102,2,223,223,1005,224,554,101,1,223,223,108,677,677,224,102,2,223,223,1006,224,569,101,1,223,223,1108,677,226,224,102,2,223,223,1005,224,584,1001,223,1,223,108,226,226,224,1002,223,2,223,1005,224,599,1001,223,1,223,1007,226,677,224,102,2,223,223,1005,224,614,1001,223,1,223,7,226,677,224,102,2,223,223,1006,224,629,1001,223,1,223,107,226,226,224,102,2,223,223,1005,224,644,101,1,223,223,7,677,226,224,102,2,223,223,1005,224,659,101,1,223,223,107,677,677,224,1002,223,2,223,1005,224,674,1001,223,1,223,4,223,99,226};

    /*char **tokens;
    size_t count;

    count = split(input, ',', &tokens);
    int numbers[count];

    if(tokens)
    {
        for(int i = 0; *(tokens + i); i++)
        {
            //printf("seen token: %s\n", *(tokens + i));
            if(i >= count) printf("Went past count\n");
            numbers[i] = atoi(*(tokens + i));
            free(*(tokens+i));
        }
    }

    free(tokens);
    */
    printf("%d\n",compute(input, IASIZE(input)));

    return 0;
}
