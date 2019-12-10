#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define IASIZE(x) (sizeof(x) / sizeof(int))
#define DEBUG 0

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

int getParam(int val, int mem[], int mode, int relbase)
{
    if(mode == 0)
    {
        return mem[val];
    }
    else if(mode == 1)
    {
        return val;
    }
    else if(mode == 2)
    {
        return mem[val + relbase];
    }
    printf("Encountered invalid parameter mode %d\n", mode);
    exit(1);
}

int compute(int input[], int length)
{
    int memsize = 200000000;
    int *numbers = calloc(memsize, sizeof(int));

    copyArray(input, numbers, length);
    int idx = 0;
    int relbase = 0;
#if DEBUG
    printf("Found %d instructions\n", length);
#endif
    while(idx < length)
    {
        int instr = numbers[idx];
#if DEBUG
        printf("Instruction: %d\n", instr);
#endif
        if (instr % 100 == 99) break;

        int opcode, param_modes;
        opcode = instr % 100; //get last digit;
        param_modes = instr / 100; //get everything preceeding opcode

        int modes[3] = {0};
        if(param_modes)
        {
            for(int i = 0; param_modes; i++)
            {
                modes[i] = param_modes % 10;
                param_modes /= 10;
            }
        }

        int op1, op2, op3, success;
        int fop1, fop2, fop3;

        op1 = numbers[idx+1];
        op2 = numbers[idx+2];
        op3 = numbers[idx+3];

        fop1 = getParam(op1, numbers, modes[0], relbase);
        fop2 = getParam(op2, numbers, modes[1], relbase);
        fop3 = modes[2] == 2 ? op3 + relbase : op3;

        switch(opcode)
        {
            case 1: // +
            case 2: // *
#if DEBUG
                printf("op: %d, modes: %d %d %d, op1: %d, op2: %d, op3: %d\n", opcode, modes[0], modes[1], modes[2], op1, op2, op3);
#endif

                if(opcode == 1) numbers[fop3] = fop1 + fop2;
                if(opcode == 2) numbers[fop3] = fop1 * fop2;
                idx += 4;
                break;
            case 3: // read input
                op2 = 0;
                printf("Awaiting input:\n");
                success = scanf("%d", &op2);
                if(success) numbers[modes[0] == 2 ? op1 + relbase : op1] = op2;
                else
                {
                    printf("Error while reading form stdin\n");
                    exit(1);
                }
                idx += 2;
                break;
            case 4: //output
#if DEBUG
                printf("op: %d, modes: %d %d %d, op1: %d = %d\n", opcode, modes[0], modes[1], modes[2], op1, numbers[op1]);
#endif
                printf("%d\n", fop1);
                idx += 2;
                break;
            case 5: // jump-if-true
                if(fop1 != 0)
                    idx = fop2;
                else
                    idx += 3;
                break;
            case 6: // jump-if-false
                if(fop1 == 0)
                    idx = fop2;
                else
                    idx += 3;
                break;
            case 7: // less than
#if DEBUG
                printf("op: %d, modes: %d %d %d, op1: %d, op2: %d, op3: %d\n", opcode, modes[0], modes[1], modes[2], op1, op2, op3);
#endif
                numbers[fop3] = (fop1 < fop2);
                idx += 4;
                break;
            case 8: // equals
#if DEBUG
                printf("op: %d, modes: %d %d %d, op1: %d, op2: %d, op3: %d\n", opcode, modes[0], modes[1], modes[2], op1, op2, op3);
#endif
                numbers[fop3] = (fop1 == fop2);
                idx += 4;
                break;
            case 9: // change relative base
                relbase += fop1;
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
    int input[] = {1102,34915192,34915192,7,4,7,99,0};//{1102,34463338,34463338,63,1007,63,34463338,63,1005,63,53,1102,1,3,1000,109,988,209,12,9,1000,209,6,209,3,203,0,1008,1000,1,63,1005,63,65,1008,1000,2,63,1005,63,904,1008,1000,0,63,1005,63,58,4,25,104,0,99,4,0,104,0,99,4,17,104,0,99,0,0,1102,533,1,1024,1102,260,1,1023,1101,33,0,1016,1102,37,1,1017,1102,1,36,1009,1101,0,35,1011,1101,0,27,1004,1101,0,0,1020,1101,242,0,1029,1101,0,31,1018,1101,0,38,1007,1101,0,29,1015,1102,1,23,1006,1101,25,0,1002,1102,1,39,1008,1101,0,20,1001,1102,1,34,1012,1102,370,1,1027,1101,30,0,1010,1102,24,1,1014,1101,21,0,1000,1101,22,0,1003,1102,1,26,1005,1101,0,267,1022,1101,1,0,1021,1101,28,0,1013,1101,0,32,1019,1101,251,0,1028,1101,377,0,1026,1102,1,524,1025,109,4,2102,1,-4,63,1008,63,21,63,1005,63,203,4,187,1105,1,207,1001,64,1,64,1002,64,2,64,109,6,1201,-1,0,63,1008,63,36,63,1005,63,229,4,213,1105,1,233,1001,64,1,64,1002,64,2,64,109,18,2106,0,0,4,239,1001,64,1,64,1106,0,251,1002,64,2,64,109,-4,2105,1,-1,1001,64,1,64,1105,1,269,4,257,1002,64,2,64,109,-6,1205,3,287,4,275,1001,64,1,64,1106,0,287,1002,64,2,64,109,-19,1202,9,1,63,1008,63,41,63,1005,63,307,1105,1,313,4,293,1001,64,1,64,1002,64,2,64,109,8,2108,23,-1,63,1005,63,331,4,319,1106,0,335,1001,64,1,64,1002,64,2,64,109,-3,21101,40,0,10,1008,1014,40,63,1005,63,361,4,341,1001,64,1,64,1106,0,361,1002,64,2,64,109,28,2106,0,-5,1001,64,1,64,1106,0,379,4,367,1002,64,2,64,109,-30,1208,7,36,63,1005,63,401,4,385,1001,64,1,64,1105,1,401,1002,64,2,64,109,-1,2101,0,6,63,1008,63,38,63,1005,63,427,4,407,1001,64,1,64,1105,1,427,1002,64,2,64,109,7,1207,-3,27,63,1005,63,445,4,433,1106,0,449,1001,64,1,64,1002,64,2,64,109,8,21107,41,40,0,1005,1016,465,1106,0,471,4,455,1001,64,1,64,1002,64,2,64,109,6,21107,42,43,-6,1005,1016,489,4,477,1105,1,493,1001,64,1,64,1002,64,2,64,109,-26,1208,8,28,63,1005,63,513,1001,64,1,64,1105,1,515,4,499,1002,64,2,64,109,29,2105,1,-1,4,521,1001,64,1,64,1105,1,533,1002,64,2,64,109,-16,1201,-4,0,63,1008,63,23,63,1005,63,553,1105,1,559,4,539,1001,64,1,64,1002,64,2,64,109,4,21101,43,0,-3,1008,1010,41,63,1005,63,579,1106,0,585,4,565,1001,64,1,64,1002,64,2,64,109,-8,1207,-3,24,63,1005,63,605,1001,64,1,64,1106,0,607,4,591,1002,64,2,64,109,1,2102,1,-2,63,1008,63,25,63,1005,63,627,1106,0,633,4,613,1001,64,1,64,1002,64,2,64,109,4,2108,25,-7,63,1005,63,653,1001,64,1,64,1106,0,655,4,639,1002,64,2,64,109,16,21102,44,1,-8,1008,1018,44,63,1005,63,681,4,661,1001,64,1,64,1106,0,681,1002,64,2,64,109,-32,1202,9,1,63,1008,63,22,63,1005,63,703,4,687,1105,1,707,1001,64,1,64,1002,64,2,64,109,1,2107,26,9,63,1005,63,725,4,713,1105,1,729,1001,64,1,64,1002,64,2,64,109,21,1206,5,745,1001,64,1,64,1106,0,747,4,735,1002,64,2,64,109,3,1205,1,763,1001,64,1,64,1106,0,765,4,753,1002,64,2,64,109,-18,2101,0,5,63,1008,63,24,63,1005,63,785,1105,1,791,4,771,1001,64,1,64,1002,64,2,64,109,6,21102,45,1,4,1008,1011,48,63,1005,63,811,1106,0,817,4,797,1001,64,1,64,1002,64,2,64,109,5,21108,46,46,1,1005,1013,835,4,823,1106,0,839,1001,64,1,64,1002,64,2,64,109,-5,21108,47,45,8,1005,1015,855,1105,1,861,4,845,1001,64,1,64,1002,64,2,64,109,9,1206,4,875,4,867,1105,1,879,1001,64,1,64,1002,64,2,64,109,-7,2107,23,-6,63,1005,63,895,1106,0,901,4,885,1001,64,1,64,4,64,99,21101,27,0,1,21101,915,0,0,1106,0,922,21201,1,51547,1,204,1,99,109,3,1207,-2,3,63,1005,63,964,21201,-2,-1,1,21101,942,0,0,1106,0,922,22102,1,1,-1,21201,-2,-3,1,21102,1,957,0,1106,0,922,22201,1,-1,-2,1106,0,968,21202,-2,1,-2,109,-3,2105,1,0};

    compute(input, IASIZE(input));

    return 0;
}
