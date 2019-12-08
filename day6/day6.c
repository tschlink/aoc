#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

ssize_t getline(char **lineptr, size_t *n, FILE *stream);

typedef struct Orbit_T
{
    char* center;
    char* orbitee;
} Orbit;

void free_string_array(char **array)
{
    for(int i = 0; *(array + i); i++)
    {
        free(*(array + i));
    }
    free(array);
}

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
    count+=2;
    result = malloc(sizeof(char*) * count);
    if(result)
    {
        size_t idx = 0;
        char *token = strtok(str, delimiter);
        while(token)
        {
            *(result+idx) = malloc(sizeof(char) * strlen(token));
            strcpy(*(result + idx), token);
            token = strtok(0, delimiter);
            idx++;
        }
        *(result + idx) = 0;
    }
    return result;
}

Orbit* get_orbits(const char *path, int *orbit_number)
{
    Orbit *orbits;
    Orbit tmp[2000];
    char *line = NULL;
    size_t len = 0;

    FILE * f = fopen(path, "r");
    if(f == NULL) {
        printf("Failed to open file.\n");
        exit(1);
    }

   int i = 0;
    while((getline(&line, &len, f)) != -1) {
        char** orb = split(line, ')');
        strcpy(tmp[i].center, orb[0]);
        strcpy(tmp[i].orbitee, orb[1]);
        free_string_array(orb);
        i++;
    }

    *orbit_number = i;
    orbits = malloc(sizeof(Orbit) * i);

    for(int j = 0; j < i; j++)
    {
        *(orbits + j) = tmp[j];
    }
    fclose(f);
    return orbits;
}

int main(void)
{
    int orbit_nbr = 0;
    Orbit *orbits = get_orbits("input.txt", &orbit_nbr);
    return 0;
}
