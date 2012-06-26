/* Program to conver a positive integer to another base */
#include <stdio.h>
#include <string.h>
// #include <stdbool.h>

int main (void)
{
    // Declare my variables
    const char baseDigits[16] = {
            '0','1','2','3','4','5','6','7',
            '8', '9', 'A','B','C','D','E','F' };
    int         convertedNumber[64];
    long int    numberToConvert;
    int         nextDigit, base, index = 0;
    int         x;
    char        chk_base[10];
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
    if (base > 16 || base < 2)
        printf("Error: Base out of acceptable range. Base is too %s\n", chk_base);
        return 1;

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
