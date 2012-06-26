/* Initializing Arrays */
#include <stdio.h>
// #include <stdbool.h>

int main (void)
{
    // Declare my variables
    int array_values[30] = {0, 1, 4, 9, 16};  
    int i;

    for ( i = 5; i < 30; ++i ) {
        array_values[i] = i * i;
        printf("%i ", i);
        if ( i == 30 - 1 ) {
            printf("\n\n");
        }
            
    }

    for ( i = 0; i < 30; ++i )
        printf ("array_values[%i] = %i\n", i, array_values[i]);
        
    return 0;

    }
