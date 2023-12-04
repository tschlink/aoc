#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>

char *strdup(const char *s);

ssize_t getline(char **lineptr, size_t *n, FILE *stream);

typedef struct Orbit_T
{
    char* center;
    char* orbitee;
} Orbit;

typedef struct Orbit_Tree_T
{
    char *planet;
    struct Orbit_Tree_T *children;
    int child_length;
    struct Orbit_Tree_T *parent;
} Orbit_Tree;

void free_string_array(char **array)
{
    for(int i = 0; *(array + i); i++)
    {
        free(*(array + i));
    }
    free(array);
}

int rtrim(char *str)
{
    if(str == NULL) return 0;
    int trimmable_chars = 0;
    int length = strlen(str);

    if(length == 0) return 0;
    if(length == 1 && *str == '\0') return 0;

    for(int i = length - 1; i > - 1; i--)
    {
        char current = str[i];
        if(current == '\0' || current == ' ' || current == '\n' || current == '\t') trimmable_chars++;
        else
        {
            str[i+1] = '\0';
            break;
        }
    }
    return trimmable_chars; // -1 to ignore trailing null byte. TODO this didn't work as expected, more debugging!
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
            rtrim(token);
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
        tmp[i].center = strdup(orb[0]);
        tmp[i].orbitee = strdup(orb[1]);
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

Orbit_Tree* createNode(char *str)
{
    Orbit_Tree *tree = calloc(1, sizeof(Orbit_Tree));
    tree->planet = strdup(str);
    tree->child_length = 0;
    return tree;
}

void addChild(Orbit_Tree *tree, Orbit *orbit)
{
    /*assert(0 == strcmp(tree->planet, orbit->center));
    Orbit_Tree *child = createNode(strdup(orbit->orbitee));

    child->parent = tree;
    parent->child_length += 1;
*/
}

Orbit_Tree* findNode(Orbit_Tree *root, char* str)
{
    if(root == NULL) return NULL;

    if(0 == strcmp(root->planet, str)) return root;

    for(int i = 0; i < root->child_length; i++)
    {
        Orbit_Tree *tmp = findNode((root->children + i), str);
        if(tmp != NULL) return tmp;
    }

    return NULL;
}

void buildTree(Orbit_Tree *root, Orbit *orbits, int length)
{
    for(int i = 0; i < 2; i++)
    {
    }
}
int main(void)
{
    int orbit_nbr = 0;
    Orbit *orbits = get_orbits("input.txt", &orbit_nbr);

    Orbit_Tree *root = createNode("COM");


    return 0;
}
