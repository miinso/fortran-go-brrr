program main
    use math_module
    use statistics
    use io_module
    implicit none
    
    integer :: n
    real, dimension(10) :: data
    
    ! Test math functions
    n = 5
    print *, "Factorial of", n, "=", factorial(n)
    print *, "Fibonacci of", n, "=", fibonacci(n)
    print *, "GCD(48, 18) =", gcd(48, 18)
    
    ! Test statistics
    data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    print *, "Mean:", mean(data)
    print *, "Std Dev:", std_dev(data)
    
    print *, "Scientific app completed!"
end program main
