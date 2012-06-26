/* Prog to calculate the 200th triangular #
Simple use of a for loop
*/
#include <stdio.h>

int main (void)
    {
        // Declare my variables
        int factorial = 1, old_factorial;
        int n = 5, old_n = n;
        
        //printf ("Table of Triangular Numbers\n\n");
        //printf ("<n>   Sum: 1 to n\n");
        //printf ("___   ___________\n");
        // Generate every 5th number, between 5 and 50
        while ( n >= 1 ) {
                
                old_factorial = factorial;
                factorial = factorial * n;
                 old_n = n; --n;
                printf (" %4i  x  %4i %10i\n", factorial, n, old_n);
               
                }
                
        /* above is equivalent to 
                triangularNumber = triangularNumber + n;
        */

        // printf ("The 200th triangular number is %i\n", triangularNumber);

        return 0;
    }
