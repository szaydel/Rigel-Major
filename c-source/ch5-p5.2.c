/* Prog to calculate the 200th triangular #
Simple use of a for loop
*/
#include <stdio.h>

int main (void)
    {
        // Declare my variables
        int n, triangularNumber;
        triangularNumber = 0;

        for ( n = 1; n <= 200; n += 1 )
                printf ("%i + %i... ", triangularNumber, n),
                triangularNumber += n;
                
        /* above is equivalent to 
                triangularNumber = triangularNumber + n;
        */

        printf ("The 200th triangular number is %i\n", triangularNumber);

        return 0;
    }
