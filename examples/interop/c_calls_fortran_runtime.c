// tests that flang_rt and clang_rt libraries are properly linked

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Fortran function declarations
extern double test_io(double x);
extern double test_intrinsics(double x);
extern double test_array_ops(int n);
extern double test_formatted_io(double x, double y);
extern int test_string_ops(void);
extern double test_runtime_checks(double x);

int main(void) {
    int errors = 0;
    double result;
    int int_result;

    printf("=== Testing Fortran Runtime Library Dependencies ===\n\n");

    // Test 1: Fortran I/O
    printf("Test 1: Fortran I/O\n");
    result = test_io(42.0);
    if (fabs(result - 84.0) > 1e-10) {
        printf("FAIL: test_io(42.0) = %f, expected 84.0\n", result);
        errors++;
    } else {
        printf("PASS: test_io(42.0) = 84.0\n");
    }
    printf("\n");

    // Test 2: Fortran intrinsic math functions
    printf("Test 2: Fortran intrinsic functions (sqrt, exp, log, sin, cos)\n");
    result = test_intrinsics(4.0);
    // Just check that we got a finite number (the actual value doesn't matter much)
    if (isfinite(result)) {
        printf("PASS: test_intrinsics(4.0) returned finite value %f\n", result);
    } else {
        printf("FAIL: test_intrinsics(4.0) returned non-finite value\n");
        errors++;
    }
    printf("\n");

    // Test 3: Array operations with dynamic allocation
    printf("Test 3: Dynamic array allocation and operations\n");
    result = test_array_ops(10);
    // Average of squares from 1 to 10: (1+4+9+16+25+36+49+64+81+100)/10 = 38.5
    double expected_avg = 38.5;
    if (fabs(result - expected_avg) > 1e-10) {
        printf("FAIL: test_array_ops(10) = %f, expected %f\n", result, expected_avg);
        errors++;
    } else {
        printf("PASS: test_array_ops(10) = %f\n", result);
    }
    printf("\n");

    // Test 4: Formatted I/O
    printf("Test 4: Formatted I/O\n");
    result = test_formatted_io(3.14159, 2.71828);
    double expected_sum = 3.14159 + 2.71828;
    if (fabs(result - expected_sum) > 1e-5) {
        printf("FAIL: test_formatted_io = %f, expected %f\n", result, expected_sum);
        errors++;
    } else {
        printf("PASS: test_formatted_io = %f\n", result);
    }
    printf("\n");

    // Test 5: String operations
    printf("Test 5: String operations\n");
    int_result = test_string_ops();
    // "Hello World" has 11 characters
    if (int_result != 11) {
        printf("FAIL: test_string_ops = %d, expected 11\n", int_result);
        errors++;
    } else {
        printf("PASS: test_string_ops = %d\n", int_result);
    }
    printf("\n");

    // Test 6: Runtime checks
    printf("Test 6: Runtime checks (positive value)\n");
    result = test_runtime_checks(16.0);
    if (fabs(result - 4.0) > 1e-10) {
        printf("FAIL: test_runtime_checks(16.0) = %f, expected 4.0\n", result);
        errors++;
    } else {
        printf("PASS: test_runtime_checks(16.0) = 4.0\n");
    }
    printf("\n");

    printf("Test 7: Runtime checks (negative value)\n");
    result = test_runtime_checks(-5.0);
    if (fabs(result - 0.0) > 1e-10) {
        printf("FAIL: test_runtime_checks(-5.0) = %f, expected 0.0\n", result);
        errors++;
    } else {
        printf("PASS: test_runtime_checks(-5.0) = 0.0\n");
    }
    printf("\n");

    // Summary
    printf("=== Test Summary ===\n");
    if (errors == 0) {
        printf("All tests passed! Runtime libraries properly linked.\n");
        return 0;
    } else {
        printf("%d test(s) failed.\n", errors);
        return 1;
    }
}
