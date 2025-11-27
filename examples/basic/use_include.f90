program use_include
    implicit none
    INCLUDE 'constants.inc'

    print *, "PI =", PI
    print *, "E =", E
    print *, "MAX_ITERATIONS =", MAX_ITERATIONS

    ! Verify values are correct
    if (abs(PI - 3.14159265358979) > 0.0001) stop 1
    if (abs(E - 2.71828182845905) > 0.0001) stop 1
    if (MAX_ITERATIONS /= 1000) stop 1

    print *, "PASSED"
end program use_include
