/* Convert Fahrengeit (F) to Celsius (C)

*/
#include <stdio.h>

int main (void)
    {
        // Declare my variables
        int cval, fval;
        float conv;
        conv = 1.8;
        fval = 27;
        cval = (fval - 32) / conv;
        
        printf("Converted degrees [F] %i to degrees [C] %i\n", fval, cval);

        return 0;
    }
