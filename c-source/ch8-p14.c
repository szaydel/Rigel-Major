// Program to conver a positive integer to another base
// enhanced from original cp7-p7 version
#include <stdio.h>
#include <string.h>
// #include <stdbool.h>

int         convertedNumber[64];
long int    numberToConvert;
int         base;
int         digit = 0;
char        chk_base[10];
void getNumberAndBase (void) {
    
    // Get the number and the base
    printf ("Number to be convered? ");
    scanf  ("%ld", &numberToConvert);

    printf ("Base? " );
    scanf  ("%i", &base);

    // Check if base is valid
    if (base > 16)
        chk_base = 'high';
    if (base < 2)
        chk_base = 'low';
    if (base > 16 || base < 2){
            printf("Error: Base out of acceptable range. Base is too %s\n", chk_base);
            printf("Defaulting base to 10 %i\n", base = 10);
        }
        // return 1;
}

int main (void)
{
    // Declare my variables
    const char baseDigits[16] = {
            '0','1','2','3','4','5','6','7',
            '8', '9', 'A','B','C','D','E','F' };

    int         x;





    // Convert to the indicated base

    do {
        printf("Next number to convert: %li\n", numberToConvert);
        convertedNumber[index] = numberToConvert % base;
        printf("Index [%i] convertedNumber is [%i]\n",index, convertedNumber[index]);
        index++;
        numberToConvert = numberToConvert / base;
        
    }
    while ( numberToConvert != 0 );

    // Display the results in reverse order
    printf("Index is currently: %i\n",index);
    printf("Converted Number = ");

    for ( index; index >= 0; --index ) {
        x = index;
        
        nextDigit = convertedNumber[index];
        printf("...[%i]", x);
        printf("%c", baseDigits[nextDigit]);
    }

    printf ("\n");
    return 0;
}
