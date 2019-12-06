#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* reverse:  reverse string s in place */
void reverse(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}
void itoa(int n, char s[])
{
    int i, sign;

    if ((sign = n) < 0)  /* record sign */
        n = -n;          /* make n positive */
    i = 0;
    do {       /* generate digits in reverse order */
        s[i++] = n % 10 + '0';   /* get next digit */
    } while ((n /= 10) > 0);     /* delete it */
    if (sign < 0)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}

int main(void)
{
    int lo = 387638;
    int hi = 919123;
    int crit_met = 0;

    for(; lo <= hi; lo++)
    {
        char buff[7];
        itoa(lo, buff);

        int found_dup = 0;
        char last = '0';
        int streak = 0;
        int dec = 0;
        for(int i = 0; i < strlen(buff); i++)
        {
            if(buff[i] < last)
            {
                dec = 1;
            }

            if(buff[i] != last)
            {
                if(streak == 1) found_dup = 1;
                last = buff[i];
                streak = 0;
            }
            else
            {
                streak++;
            }
        }

        if((found_dup || (streak == 1)) && !dec)
        {
           crit_met ++;
        }
    }

    printf("Found a total number of %d matching passwords\n", crit_met);
    return 0;
}
