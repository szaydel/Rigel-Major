/* Prog to calculate the 200th triangular #
Simple use of a for loop
*/
#include <stdio.h>

int main (void)
    {
        // Declare my variables
        int n, triangularNumber;
        triangularNumber = 0;
        printf ("Table of Triangular Numbers\n\n");
        printf ("<n>   Sum: 1 to n\n");
        printf ("___   ___________\n");
        for ( n = 1; n <= 10; ++n ) {
                //printf ("%i + %i... ", triangularNumber, n),
                triangularNumber += n;
                printf (" %-8i %i\n", n, triangularNumber);
                }
                
        /* above is equivalent to 
                triangularNumber = triangularNumber + n;
        */

        // printf ("The 200th triangular number is %i\n", triangularNumber);

        return 0;
    }
