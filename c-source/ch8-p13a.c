// Program to perform some action for each value in a multidimensional array

#include <stdio.h>

void sort (int a[], int n) {
    int i, j, temp;
    for ( i = 0; i < n - 1; ++i )
        for ( j = i + 1; j < n; ++j )
            printf("i = [%i] j = [%i]\n", i, j);
            if ( a[i] > a[j] ) {
                temp = a[i];
                a[i] = a[j];
                a[j] = temp;
            }
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

    printf("\n\nThe array before the sort:\n");

    for ( arrIndex = 0; arrIndex < arrLength; ++arrIndex )
        printf("%-4i ", arrValues[arrIndex]);

    sort (arrValues, arrLength);

    printf("\n\nThe array after the sort:\n");
    
    for ( arrIndex = 0; arrIndex < arrLength; ++arrIndex )
        printf("%-4i ", arrValues[arrIndex]);
    
    return 0;

}
