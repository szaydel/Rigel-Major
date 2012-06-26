/*

*/
#include <stdio.h>

int main (void)
    {
        // Declare my variables
        
        float x, x_sq, x_cu;
        x = 2.55;
        x_sq = x * x;
        x_cu = x_sq * x;

        printf("Value of x:\n %-15f\nx squared: %-15f\nx cubed: %-15f\nResult: %f\n",
                x, x_sq, x_cu, ((3 * x_cu) - (5 * x_sq) + 6));

        return 0;
    }
