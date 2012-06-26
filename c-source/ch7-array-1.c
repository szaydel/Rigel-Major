#include <stdio.h>
#include <string.h>

// Declare Variables here
int arr1[4][4] = {
                    {1,2,3,4},
                    {4,5,6,7},
                    {8,9,10,11},
                    {12,13,14,15}
                };
int vert, horz;

int main (void)
{
    printf("Please enter Vertical from 0 to 3:\n");
    scanf("%i",&vert);
    
    if (vert > 3 || vert < 0) {
        printf("Invalid Vertical, number not between 0 and 3:\n");
    }

    printf("Please enter Horizontal from 0 to 3:\n");
    scanf("%i",&horz);
    
    if (horz > 3 || horz < 0) {
        printf("Invalid Vertical, number not between 0 and 3:\n");
    }

    printf("Your number is: %i\n", arr1[vert][horz]);
    return 0;

    };
