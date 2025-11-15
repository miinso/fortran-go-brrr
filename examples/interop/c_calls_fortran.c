#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// use bind(c) to ensure C-compatible name mangling.
extern double fortran_square(double x);

int main(void) {
    int errors = 0;

    double result1 = fortran_square(5.0);
    if (fabs(result1 - 25.0) > 1e-10) {
        printf("FAIL: fortran_square(5.0) = %f, expected 25.0\n", result1);
        errors++;
    } else {
        printf("PASS: fortran_square(5.0) = 25.0\n");
    }
}
