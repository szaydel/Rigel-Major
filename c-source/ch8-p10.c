// Function to find minimum value in an array

#include <stdio.h>

int minimum (int values[], int numberOfElements) {
    int minValue, i;
    minValue = values[0]; // Out of the gate, we assume this to be minumum value

    // For each index item in values array 
    for ( i = 1; i < numberOfElements; ++i )
        if ( values[i] < minValue )
            minValue = values[i];
    
    return minValue;
}

int arrLength = 0, arrIndex;

int tempValue;

int main (void) {
    printf("Length of Array: ");
    scanf("%i", &arrLength);
    int arrValues[arrLength];

    for ( arrIndex = 0; arrIndex < arrLength; ++arrIndex ) {
            printf("Enter value for Idx[%i] ", arrIndex);
            scanf("%i", &tempValue);
            arrValues[arrIndex] = tempValue;
            tempValue = 0;
        }
    int minumum ( int values[], int numberOfElements );

    printf("Array minimum: %i\n", minimum (arrValues, arrLength));
    return 0;

}
