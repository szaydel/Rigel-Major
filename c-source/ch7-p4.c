/* Prog to calculate the 200th triangular #
Simple use of a for loop
*/
#include <stdio.h>
#include <stdbool.h>

// Modified program to generate prime numbers
int main (void)
    {
        // Declare my variables
        int p, i, primes[50], primeIndex = 2;
        bool isPrime;

        primes[0] = 2;
        primes[1] = 3;

        for ( p = 5; p <= 50; p = p + 2 ) {
            //printf("%i\n", p);
            isPrime = true;
                
            for ( i = 1; isPrime && p/primes[i] >= primes[i]; ++i )
                printf("[%i] %i\n", primes[i], p);
                if ( p % primes[i] == 0 )
                    isPrime = false;
        
            if ( isPrime == true ) {
                primes[primeIndex]= p;
                printf("%i\n", primeIndex);
                ++primeIndex;

            }

        }
        for ( i = 0; i < primeIndex; ++i )
            printf("%i ", primes[i] );
    
        printf("\n");
        
        return 0;
    }
