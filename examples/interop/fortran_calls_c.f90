program fortran_calls_c
    use iso_c_binding, only: c_double
    implicit none

    ! Interface to C function
    interface
        function c_add_doubles(a, b) bind(c, name="c_add_doubles")
            import :: c_double
            real(c_double), value :: a, b
            real(c_double) :: c_add_doubles
        end function c_add_doubles
    end interface

    ! Test variables
    real(c_double) :: result

    ! simple addition
    result = c_add_doubles(2.0d0, 3.0d0)
    if (abs(result - 5.0d0) > 1.0d-10) then
        print *, "FAIL: c_add_doubles(2.0, 3.0) = ", result, " expected 5.0"
    else
        print *, "PASS: c_add_doubles(2.0, 3.0) = 5.0"
    end if

end program fortran_calls_c
