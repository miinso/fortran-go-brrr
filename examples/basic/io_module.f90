module io_module
    implicit none
    private
    public :: read_array, write_array, print_matrix
    
contains
    
    subroutine read_array(filename, data)
        character(len=*), intent(in) :: filename
        real, dimension(:), allocatable, intent(out) :: data
        integer :: unit, n, i, iostat
        
        open(newunit=unit, file=filename, status='old', action='read')
        read(unit, *) n
        allocate(data(n))
        do i = 1, n
            read(unit, *, iostat=iostat) data(i)
            if (iostat /= 0) exit
        end do
        close(unit)
    end subroutine read_array
    
    subroutine write_array(filename, data)
        character(len=*), intent(in) :: filename
        real, dimension(:), intent(in) :: data
        integer :: unit, i
        
        open(newunit=unit, file=filename, status='replace', action='write')
        write(unit, *) size(data)
        do i = 1, size(data)
            write(unit, *) data(i)
        end do
        close(unit)
    end subroutine write_array
    
    subroutine print_matrix(matrix)
        real, dimension(:,:), intent(in) :: matrix
        integer :: i
        
        do i = 1, size(matrix, 1)
            print *, matrix(i, :)
        end do
    end subroutine print_matrix
    
end module io_module
