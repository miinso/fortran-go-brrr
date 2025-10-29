module statistics
    implicit none
    private
    public :: mean, variance, std_dev
    
contains
    
    function mean(data) result(m)
        real, dimension(:), intent(in) :: data
        real :: m
        m = sum(data) / size(data)
    end function mean
    
    function variance(data) result(v)
        real, dimension(:), intent(in) :: data
        real :: v, m
        m = mean(data)
        v = sum((data - m)**2) / size(data)
    end function variance
    
    function std_dev(data) result(s)
        real, dimension(:), intent(in) :: data
        real :: s
        s = sqrt(variance(data))
    end function std_dev
    
end module statistics
