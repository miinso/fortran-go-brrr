module core
    implicit none
    public :: vector, vector_add
    
    type :: vector
        real, dimension(:), allocatable :: data
    end type vector
    
contains
    
    function vector_add(v1, v2) result(v3)
        type(vector), intent(in) :: v1, v2
        type(vector) :: v3
        allocate(v3%data(size(v1%data)))
        v3%data = v1%data + v2%data
    end function vector_add
    
end module core
