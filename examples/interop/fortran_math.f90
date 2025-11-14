module fortran_math_mod
    use iso_c_binding, only: c_double
    implicit none

contains

    ! Function callable from C
    ! The bind(c, name="...") attribute ensures C-compatible name mangling
    function fortran_square(x) bind(c, name="fortran_square")
        real(c_double), value :: x  ! value attribute for pass-by-value (C convention)
        real(c_double) :: fortran_square

        fortran_square = x * x
    end function fortran_square

end module fortran_math_mod
