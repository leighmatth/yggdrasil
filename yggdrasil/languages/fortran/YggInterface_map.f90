! Interface for getting/setting generic map elements
! Get methods
function generic_map_get_boolean(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  logical(kind=1), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_item(x, key, "boolean")
  call c_f_pointer(c_out, out)
end function generic_map_get_boolean
function generic_map_get_integer(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=c_int), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_item(x, key, "integer")
  call c_f_pointer(c_out, out)
end function generic_map_get_integer
function generic_map_get_null(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggnull) :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_item(x, key, "null")
  ! call c_f_pointer(c_out%ptr, out)
end function generic_map_get_null
function generic_map_get_number(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=8), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_item(x, key, "number")
  call c_f_pointer(c_out, out)
end function generic_map_get_number
function generic_map_get_string(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(len=:, kind=c_char), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_item(x, key, "string")
  call c_f_pointer(c_out, out)
end function generic_map_get_string
function generic_map_get_map(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygggeneric) :: out
  out = init_generic()
  out%obj = generic_map_get_item(x, key, "object")
end function generic_map_get_map
function generic_map_get_array(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygggeneric) :: out
  out = init_generic()
  out%obj = generic_map_get_item(x, key, "array")
end function generic_map_get_array
function generic_map_get_ply(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(c_ptr) :: c_out
  type(yggply), pointer :: out
  c_out = generic_map_get_item(x, key, "ply")
  ! Copy?
  call c_f_pointer(c_out, out)
end function generic_map_get_ply
function generic_map_get_obj(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(c_ptr) :: c_out
  type(yggobj), pointer :: out
  c_out = generic_map_get_item(x, key, "obj")
  ! Copy?
  call c_f_pointer(c_out, out)
end function generic_map_get_obj
function generic_map_get_python_class(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(c_ptr) :: c_out
  type(yggpython), pointer :: out
  c_out = generic_map_get_item(x, key, "class")
  ! Copy?
  call c_f_pointer(c_out, out)
end function generic_map_get_python_class
function generic_map_get_python_function(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(c_ptr) :: c_out
  type(yggpython), pointer :: out
  c_out = generic_map_get_item(x, key, "function")
  ! Copy?
  call c_f_pointer(c_out, out)
end function generic_map_get_python_function
function generic_map_get_schema(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygggeneric) :: out
  out = init_generic()
  out%obj = generic_map_get_item(x, key, "schema")
end function generic_map_get_schema
function generic_map_get_any(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygggeneric) :: out
  out = init_generic()
  out%obj = generic_map_get_item(x, key, "any")
end function generic_map_get_any
! Get scalar int
function generic_map_get_integer2(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=2), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "int", 8 * 2)
  call c_f_pointer(c_out, out)
end function generic_map_get_integer2
function generic_map_get_integer4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=4), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "int", 8 * 4)
  call c_f_pointer(c_out, out)
end function generic_map_get_integer4
function generic_map_get_integer8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=8), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "int", 8 * 8)
  call c_f_pointer(c_out, out)
end function generic_map_get_integer8
! Get scalar uint
function generic_map_get_unsigned1(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint1) :: out
  integer(kind=1), pointer :: temp
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "uint", 8 * 1)
  call c_f_pointer(c_out, temp)
  out%x = temp
  deallocate(temp)
end function generic_map_get_unsigned1
function generic_map_get_unsigned2(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint2) :: out
  integer(kind=2), pointer :: temp
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "uint", 8 * 2)
  call c_f_pointer(c_out, temp)
  out%x = temp
  deallocate(temp)
end function generic_map_get_unsigned2
function generic_map_get_unsigned4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint4) :: out
  integer(kind=4), pointer :: temp
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "uint", 8 * 4)
  call c_f_pointer(c_out, temp)
  out%x = temp
  deallocate(temp)
end function generic_map_get_unsigned4
function generic_map_get_unsigned8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint8) :: out
  integer(kind=8), pointer :: temp
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "uint", 8 * 8)
  call c_f_pointer(c_out, temp)
  out%x = temp
  deallocate(temp)
end function generic_map_get_unsigned8
! Get scalar real
function generic_map_get_real4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=4), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "float", 8 * 4)
  call c_f_pointer(c_out, out)
end function generic_map_get_real4
function generic_map_get_real8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=8), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "float", 8 * 8)
  call c_f_pointer(c_out, out)
end function generic_map_get_real8
! Get scalar complex
function generic_map_get_complex4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=4), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "complex", 8 * 4)
  call c_f_pointer(c_out, out)
end function generic_map_get_complex4
function generic_map_get_complex8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=8), pointer :: out
  type(c_ptr) :: c_out
  c_out = generic_map_get_scalar(x, key, "complex", 8 * 8)
  call c_f_pointer(c_out, out)
end function generic_map_get_complex8
! Get scalar string
function generic_map_get_bytes(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(len=:), pointer :: out
  character, dimension(:), pointer :: temp
  type(c_ptr) :: c_out
  integer :: length, i
  c_out = generic_map_get_scalar(x, key, "bytes", 0)
  length = generic_map_get_item_nbytes(x, key)
  call c_f_pointer(c_out, temp, [length])
  allocate(character(len=length) :: out)
  do i = 1, length
     out(i:i) = temp(i)
  end do
  deallocate(temp)
end function generic_map_get_bytes
function generic_map_get_unicode(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(kind=ucs4, len=:), pointer :: out
  character(kind=ucs4), dimension(:), pointer :: temp
  type(c_ptr) :: c_out
  integer :: length, i
  c_out = generic_map_get_scalar(x, key, "unicode", 0)
  length = generic_map_get_item_nbytes(x, key)/4
  call c_f_pointer(c_out, temp, [length])
  allocate(character(kind=ucs4, len=length) :: out)
  do i = 1, length
     out(i:i) = temp(i)
  end do
  deallocate(temp)
end function generic_map_get_unicode

! Get 1darray int
function generic_map_get_1darray_integer2(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=2), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "int", 8 * 2, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_integer2
function generic_map_get_1darray_integer4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=4), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "int", 8 * 4, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_integer4
function generic_map_get_1darray_integer8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=8), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "int", 8 * 8, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_integer8
! Get 1darray uint
function generic_map_get_1darray_unsigned1(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint1), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "uint", 8 * 1, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_unsigned1
function generic_map_get_1darray_unsigned2(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint2), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "uint", 8 * 2, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_unsigned2
function generic_map_get_1darray_unsigned4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint4), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "uint", 8 * 4, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_unsigned4
function generic_map_get_1darray_unsigned8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint8), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "uint", 8 * 8, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_unsigned8
! Get 1darray real
function generic_map_get_1darray_real4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=4), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "float", 8 * 4, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_real4
function generic_map_get_1darray_real8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=8), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "float", 8 * 8, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_real8
! Get 1darray complex
function generic_map_get_1darray_complex4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=4), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "complex", 8 * 4, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_complex4
function generic_map_get_1darray_complex8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=8), dimension(:), pointer :: out
  integer(kind=c_size_t) :: c_length
  type(c_ptr), target :: c_out
  c_length = generic_map_get_1darray(x, key, "complex", 8 * 8, c_loc(c_out))
  call c_f_pointer(c_out, out, [c_length])
end function generic_map_get_1darray_complex8
! Get 1darray string
function generic_map_get_1darray_bytes(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(len=:), dimension(:), pointer :: out
  character, dimension(:), pointer :: temp
  type(c_ptr), target :: c_out
  integer(kind=c_size_t) :: c_length, i
  integer :: nbytes, precision, j
  c_length = generic_map_get_1darray(x, key, "bytes", 0, c_loc(c_out))
  nbytes = generic_map_get_item_nbytes(x, key)
  precision = nbytes/int(c_length, kind=4)
  call c_f_pointer(c_out, temp, [nbytes])
  allocate(character(len=precision) :: out(c_length))
  do i = 1, c_length
     do j = 1, precision
        out(i)(j:j) = temp((i-1)*precision + j)
     end do
  end do
  deallocate(temp)
end function generic_map_get_1darray_bytes
function generic_map_get_1darray_unicode(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(kind=ucs4, len=:), dimension(:), pointer :: out
  character(kind=ucs4), dimension(:), pointer :: temp
  type(c_ptr), target :: c_out
  integer(kind=c_size_t) :: c_length, i
  integer :: nbytes, precision, j
  c_length = generic_map_get_1darray(x, key, "unicode", 0, c_loc(c_out))
  nbytes = generic_map_get_item_nbytes(x, key)
  precision = nbytes/(int(c_length, kind=4)*4)
  call c_f_pointer(c_out, temp, [nbytes/4])
  allocate(character(kind=ucs4, len=precision) :: out(c_length))
  do i = 1, c_length
     do j = 1, precision
        out(i)(j:j) = temp((i-1)*precision + j)
     end do
  end do
  deallocate(temp)
end function generic_map_get_1darray_unicode

! Get ndarray int
function generic_map_get_ndarray_integer2(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(integer2_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "int", 8 * 2, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_integer2
function generic_map_get_ndarray_integer4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(integer4_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "int", 8 * 4, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_integer4
function generic_map_get_ndarray_integer8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(integer8_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "int", 8 * 8, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_integer8
! Get ndarray uint
function generic_map_get_ndarray_unsigned1(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned1_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "uint", 8 * 1, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_unsigned1
function generic_map_get_ndarray_unsigned2(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned2_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "uint", 8 * 2, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_unsigned2
function generic_map_get_ndarray_unsigned4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned4_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "uint", 8 * 4, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_unsigned4
function generic_map_get_ndarray_unsigned8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned8_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "uint", 8 * 8, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_unsigned8
! Get ndarray real
function generic_map_get_ndarray_real4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(real4_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "float", 8 * 4, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_real4
function generic_map_get_ndarray_real8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(real8_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "float", 8 * 8, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_real8
! Get ndarray complex
function generic_map_get_ndarray_complex4(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(complex4_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "complex", 8 * 4, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_complex4
function generic_map_get_ndarray_complex8(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(complex8_nd) :: out
  type(c_ptr), target :: c_out
  out%shape => generic_map_get_ndarray(x, key, "complex", 8 * 8, &
       c_loc(c_out))
  call c_f_pointer(c_out, out%x, out%shape)
end function generic_map_get_ndarray_complex8
! Get ndarray string
function generic_map_get_ndarray_character(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(character_nd) :: out
  character, dimension(:), pointer :: temp
  type(c_ptr), target :: c_out
  integer(kind=c_size_t) :: precision, nelements, i, j
  integer(kind=c_int) :: nbytes
  out%shape => generic_map_get_ndarray(x, key, "bytes", 0, &
       c_loc(c_out))
  nbytes = generic_map_get_item_nbytes(x, key)
  nelements = 1
  do i = 1, size(out%shape)
     nelements = nelements * out%shape(i)
  end do
  precision = nbytes/nelements
  call c_f_pointer(c_out, temp, [nbytes])
  allocate(out%x(nelements))
  do i = 1, nelements
     allocate(out%x(i)%x(precision))
     do j = 1, precision
        out%x(i)%x(j) = temp((i-1)*precision + j)
     end do
  end do
  deallocate(temp)
end function generic_map_get_ndarray_character
function generic_map_get_ndarray_bytes(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(bytes_nd) :: out
  character, dimension(:), pointer :: temp
  type(c_ptr), target :: c_out
  integer(kind=c_size_t) :: precision, nelements, i, j
  integer(kind=c_int) :: nbytes
  out%shape => generic_map_get_ndarray(x, key, "bytes", 0, &
       c_loc(c_out))
  nbytes = generic_map_get_item_nbytes(x, key)
  nelements = 1
  do i = 1, size(out%shape)
     nelements = nelements * out%shape(i)
  end do
  precision = nbytes/nelements
  call c_f_pointer(c_out, temp, [nbytes])
  allocate(character(len=precision) :: out%x(nelements))
  do i = 1, nelements
     do j = 1, precision
        out%x(i)(j:j) = temp(((i-1)*precision) + j)
     end do
  end do
  deallocate(temp)
end function generic_map_get_ndarray_bytes
function generic_map_get_ndarray_unicode(x, key) result(out)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unicode_nd) :: out
  character(kind=ucs4), dimension(:), pointer :: temp
  type(c_ptr), target :: c_out
  integer(kind=c_size_t) :: precision, nelements, i, j
  integer(kind=c_int) :: nbytes
  out%shape => generic_map_get_ndarray(x, key, "unicode", 0, &
       c_loc(c_out))
  nbytes = generic_map_get_item_nbytes(x, key)
  nelements = 1
  do i = 1, size(out%shape)
     nelements = nelements * out%shape(i)
  end do
  precision = nbytes/(nelements*4)
  call c_f_pointer(c_out, temp, [nbytes/4])
  allocate(character(len=precision, kind=ucs4) :: out%x(nelements))
  do i = 1, nelements
     do j = 1, precision
        out%x(i)(j:j) = temp(((i-1)*precision) + j)
     end do
  end do
end function generic_map_get_ndarray_unicode


! Set methods
subroutine generic_map_set_boolean(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  logical(kind=1), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "boolean", c_val)
end subroutine generic_map_set_boolean
subroutine generic_map_set_integer(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=c_int), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "integer", c_val)
end subroutine generic_map_set_integer
subroutine generic_map_set_null(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggnull), intent(in) :: val
  type(c_ptr) :: c_val
  c_val = c_null_ptr
  call generic_map_set_item(x, key, "null", c_val)
end subroutine generic_map_set_null
subroutine generic_map_set_number(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=8), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "number", c_val)
end subroutine generic_map_set_number
subroutine generic_map_set_array(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggarr), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "array", c_val)
end subroutine generic_map_set_array
subroutine generic_map_set_map(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggmap), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "object", c_val)
end subroutine generic_map_set_map
subroutine generic_map_set_ply(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggply), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "ply", c_val)
end subroutine generic_map_set_ply
subroutine generic_map_set_obj(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggobj), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "obj", c_val)
end subroutine generic_map_set_obj
subroutine generic_map_set_python_class(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggpython), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "class", c_val)
end subroutine generic_map_set_python_class
subroutine generic_map_set_python_function(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggpython), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "function", c_val)
end subroutine generic_map_set_python_function
subroutine generic_map_set_schema(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(yggschema), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "schema", c_val)
end subroutine generic_map_set_schema
subroutine generic_map_set_any(x, key, val)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygggeneric), intent(in), target :: val
  type(c_ptr) :: c_val
  c_val = c_loc(val)
  call generic_map_set_item(x, key, "any", c_val)
end subroutine generic_map_set_any
! Set scalar int
subroutine generic_map_set_integer2(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=2), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "int", 2 * 8, units)
end subroutine generic_map_set_integer2
subroutine generic_map_set_integer4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=4), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "int", 4 * 8, units)
end subroutine generic_map_set_integer4
subroutine generic_map_set_integer8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=8), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "int", 8 * 8, units)
end subroutine generic_map_set_integer8
! Set scalar uint
subroutine generic_map_set_unsigned1(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint1), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x)
  call generic_map_set_scalar(x, key, c_val, "uint", 1 * 8, units)
end subroutine generic_map_set_unsigned1
subroutine generic_map_set_unsigned2(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint2), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x)
  call generic_map_set_scalar(x, key, c_val, "uint", 2 * 8, units)
end subroutine generic_map_set_unsigned2
subroutine generic_map_set_unsigned4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint4), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x)
  call generic_map_set_scalar(x, key, c_val, "uint", 4 * 8, units)
end subroutine generic_map_set_unsigned4
subroutine generic_map_set_unsigned8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint8), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x)
  call generic_map_set_scalar(x, key, c_val, "uint", 8 * 8, units)
end subroutine generic_map_set_unsigned8
! Set scalar real
subroutine generic_map_set_real4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=4), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "float", 4 * 8, units)
end subroutine generic_map_set_real4
subroutine generic_map_set_real8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=8), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "float", 8 * 8, units)
end subroutine generic_map_set_real8
! Set scalar complex
subroutine generic_map_set_complex4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=4), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "complex", 4 * 8, units)
end subroutine generic_map_set_complex4
subroutine generic_map_set_complex8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=8), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  call generic_map_set_scalar(x, key, c_val, "complex", 8 * 8, units)
end subroutine generic_map_set_complex8
! Set scalar string
subroutine generic_map_set_bytes(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(len=*), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  ! TODO: Convert to 1d array of characters?
  call generic_map_set_scalar(x, key, c_val, "bytes", 0, units)
end subroutine generic_map_set_bytes
subroutine generic_map_set_unicode(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(kind=ucs4, len=*), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val)
  ! TODO: Convert to 1d array of characters?
  call generic_map_set_scalar(x, key, c_val, "unicode", 0, units)
end subroutine generic_map_set_unicode

! Set 1darray int
subroutine generic_map_set_1darray_integer2(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=2), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "int", 2 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_integer2
subroutine generic_map_set_1darray_integer4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=4), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "int", 4 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_integer4
subroutine generic_map_set_1darray_integer8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  integer(kind=8), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "int", 8 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_integer8
! Set 1darray uint
subroutine generic_map_set_1darray_unsigned1(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint1), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "uint", 1 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_unsigned1
subroutine generic_map_set_1darray_unsigned2(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint2), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "uint", 2 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_unsigned2
subroutine generic_map_set_1darray_unsigned4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint4), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "uint", 4 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_unsigned4
subroutine generic_map_set_1darray_unsigned8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(ygguint8), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "uint", 8 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_unsigned8
! Set 1darray real
subroutine generic_map_set_1darray_real4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=4), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "float", 4 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_real4
subroutine generic_map_set_1darray_real8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  real(kind=8), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "float", 8 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_real8
! Set 1darray complex
subroutine generic_map_set_1darray_complex4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=4), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "complex", 4 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_complex4
subroutine generic_map_set_1darray_complex8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  complex(kind=8), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  call generic_map_set_1darray(x, key, c_val, "complex", 8 * 8, &
       size(val), units)
end subroutine generic_map_set_1darray_complex8
! Set 1darray string
subroutine generic_map_set_1darray_bytes(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(len=*), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  ! TODO: Convert to 1d array of characters?
  call generic_map_set_1darray(x, key, c_val, "bytes", 0, &
       size(val), units)
end subroutine generic_map_set_1darray_bytes
subroutine generic_map_set_1darray_unicode(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  character(kind=ucs4, len=*), dimension(:), intent(in), target :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val(1))
  ! TODO: Convert to 1d array of characters?
  call generic_map_set_1darray(x, key, c_val, "unicode", 0, &
       size(val), units)
end subroutine generic_map_set_1darray_unicode

! Set ndarray int
subroutine generic_map_set_ndarray_integer2(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(integer2_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "int", 2 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_integer2
subroutine generic_map_set_ndarray_integer4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(integer4_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "int", 4 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_integer4
subroutine generic_map_set_ndarray_integer8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(integer8_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "int", 8 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_integer8
! Get ndarray uint
subroutine generic_map_set_ndarray_unsigned1(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned1_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "uint", 1 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_unsigned1
subroutine generic_map_set_ndarray_unsigned2(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned2_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "uint", 2 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_unsigned2
subroutine generic_map_set_ndarray_unsigned4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned4_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "uint", 4 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_unsigned4
subroutine generic_map_set_ndarray_unsigned8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unsigned8_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "uint", 8 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_unsigned8
! Set ndarray real
subroutine generic_map_set_ndarray_real4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(real4_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "float", 4 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_real4
subroutine generic_map_set_ndarray_real8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(real8_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "float", 8 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_real8
! Set ndarray complex
subroutine generic_map_set_ndarray_complex4(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(complex4_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "complex", 4 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_complex4
subroutine generic_map_set_ndarray_complex8(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(complex8_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "complex", 8 * 8, &
       val%shape, units)
end subroutine generic_map_set_ndarray_complex8
! Set ndarray string
subroutine generic_map_set_ndarray_character(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(character_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x(1))
  call generic_map_set_ndarray(x, key, c_val, "bytes", 0, &
       val%shape, units)
end subroutine generic_map_set_ndarray_character
subroutine generic_map_set_ndarray_bytes(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(bytes_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x)
  call generic_map_set_ndarray(x, key, c_val, "bytes", 0, &
       val%shape, units)
end subroutine generic_map_set_ndarray_bytes
subroutine generic_map_set_ndarray_unicode(x, key, val, units_in)
  implicit none
  type(ygggeneric) :: x
  character(len=*) :: key
  type(unicode_nd), intent(in) :: val
  character(len=*), intent(in), optional, target :: units_in
  character(len=:), pointer :: units
  type(c_ptr) :: c_val
  if (present(units_in)) then
     units => units_in
  else
     allocate(character(len=0) :: units)
     units = ""
  end if
  c_val = c_loc(val%x)
  call generic_map_set_ndarray(x, key, c_val, "unicode", 0, &
       val%shape, units)
end subroutine generic_map_set_ndarray_unicode
