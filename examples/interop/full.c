#include <lapacke.h>
#include <stdio.h>

int main() {
    double A[9] = {1, 2, 3, 4, 5, 6, 7, 8, 10};
    int ipiv[3];
    int info = LAPACKE_dgetrf(LAPACK_COL_MAJOR, 3, 3, A, 3, ipiv);

    printf(info ? "FAIL\n" : "OK\n");
    for (int i = 0; i < 9; i++)
        printf("%8.2f%c", A[i], (i+1)%3 ? ' ' : '\n');
    return info;
}
