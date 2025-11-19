module math_module
    implicit none
    private
    public :: factorial, fibonacci, gcd
    
contains
    
    function factorial(n) result(fact)
        integer, intent(in) :: n
        integer :: fact
        integer :: i
        
        fact = 1
        do i = 2, n
            fact = fact * i
        end do
    end function factorial
    
    recursive function fibonacci(n) result(fib)
        integer, intent(in) :: n
        integer :: fib
        
        if (n <= 1) then
            fib = n
        else
            fib = fibonacci(n-1) + fibonacci(n-2)
        end if
    end function fibonacci
    
    recursive function gcd(a, b) result(g)
        integer, intent(in) :: a, b
        integer :: g
        
        if (b == 0) then
            g = a
        else
            g = gcd(b, mod(a, b))
        end if
    end function gcd
    
end module math_module
