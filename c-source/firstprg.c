/* This is a rather basic program to test my math skills

*/
#include <stdio.h>

int main (void)
    {
        // Declare my variables
        int val1, val2, sum;
        val1 = 50;
        val2 = 25;
        sum = val1 + val2;
        short int val3 = 123;
        
        printf("Sum of %i and %i is %i\n", val1, val2, (val1 + val2));
        printf("Value of %i + %i sq. is %i\n", val1, val2, sum * sum );
        printf("My short integer %hi\n", val3);
        return 0;
    }
