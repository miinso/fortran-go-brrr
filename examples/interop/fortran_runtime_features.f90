! routines that (probably) depend on flang_rt
module fortran_runtime_features_mod
    use iso_c_binding, only: c_double, c_int
    implicit none

contains

    ! uses Fortran I/O
    function test_io(x) bind(c, name="test_io")
        real(c_double), value :: x
        real(c_double) :: test_io
        
        print *, "Fortran I/O: input value =", x
        
        test_io = x * 2.0
    end function test_io

    ! uses intrinsic math functions
    function test_intrinsics(x) bind(c, name="test_intrinsics")
        real(c_double), value :: x
        real(c_double) :: test_intrinsics
        real(c_double) :: temp
        
        temp = sqrt(x)
        temp = exp(temp)
        temp = log(temp)
        temp = sin(temp)
        temp = cos(temp)
        
        print *, "Fortran intrinsics: sqrt->exp->log->sin->cos of", x, "=", temp
        
        test_intrinsics = temp
    end function test_intrinsics

    ! uses array operations
    function test_array_ops(n) bind(c, name="test_array_ops")
        integer(c_int), value :: n
        real(c_double) :: test_array_ops
        real(c_double), allocatable :: arr(:)
        integer :: i
        
        ! malloc - requires runtime support
        allocate(arr(n))
        
        ! array init
        do i = 1, n
            arr(i) = real(i, c_double) ** 2
        end do
        
        ! array ops
        test_array_ops = sum(arr) / real(n, c_double)
        
        print *, "Fortran array ops: average of squares from 1 to", n, "=", test_array_ops
        
        ! duh
        deallocate(arr)
    end function test_array_ops

    ! uses formatted I/O
    function test_formatted_io(x, y) bind(c, name="test_formatted_io")
        real(c_double), value :: x, y
        real(c_double) :: test_formatted_io
        character(len=100) :: buffer
        
        write(buffer, '(A,F10.3,A,F10.3)') "Values: x=", x, " y=", y
        print *, trim(buffer)
        
        test_formatted_io = x + y
    end function test_formatted_io

    ! uses character operations
    function test_string_ops() bind(c, name="test_string_ops")
        integer(c_int) :: test_string_ops
        character(len=50) :: str1, str2, str3
        
        str1 = "Hello"
        str2 = "World"
        str3 = trim(str1) // " " // trim(str2)
        
        print *, "Fortran string ops: ", trim(str3)
        
        test_string_ops = len_trim(str3)
    end function test_string_ops

    ! uses error handling
    function test_runtime_checks(x) bind(c, name="test_runtime_checks")
        real(c_double), value :: x
        real(c_double) :: test_runtime_checks
        real(c_double) :: result
        
        if (x > 0.0) then
            result = sqrt(x)
            print *, "Fortran runtime checks: sqrt of positive", x, "=", result
        else
            result = 0.0
            print *, "Fortran runtime checks: skipped sqrt of non-positive", x
        end if
        
        test_runtime_checks = result
    end function test_runtime_checks

end module fortran_runtime_features_mod
