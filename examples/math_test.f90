program math_test
    use math_module
    implicit none
    
    integer :: errors
    
    errors = 0
    
    ! Test factorial
    if (factorial(5) /= 120) then
        print *, "FAIL: factorial(5)"
        errors = errors + 1
    end if
    
    if (factorial(0) /= 1) then
        print *, "FAIL: factorial(0)"
        errors = errors + 1
    end if
    
    ! Test fibonacci
    if (fibonacci(7) /= 13) then
        print *, "FAIL: fibonacci(7)"
        errors = errors + 1
    end if
    
    ! Test gcd
    if (gcd(48, 18) /= 6) then
        print *, "FAIL: gcd(48, 18)"
        errors = errors + 1
    end if
    
    if (errors == 0) then
        print *, "All tests passed!"
    else
        print *, "Tests failed:", errors
        stop 1
    end if
end program math_test
