program main
  ! Include methods for input/output channels
  use fygg

  ! Declare resulting variables and create buffer for received message
  logical :: flag = .true.
  type(yggcomm) :: in_channel, out_channel
  type(ygggeneric) :: obj
  character(len=:), dimension(:), allocatable :: keys
  type(ygggeneric) :: amaxtb
  real(kind=8), dimension(:), pointer :: amaxtb_x, amaxtb_y
  real(kind=8) :: co2
  integer :: i
  obj = init_generic()

  ! Initialize input/output channels
  in_channel = ygg_generic_input("input")
  out_channel = ygg_generic_output("output")

  ! Loop until there is no longer input or the queues are closed
  do while (flag)

     ! Receive input from input channel
     ! If there is an error, the flag will be false
     ! Otherwise, it is the number of variables filled
     flag = ygg_recv_var(in_channel, yggarg(obj))
     if (.not.flag) then
        write (*, '("Fortran Model: No more input.")')
        exit
     end if

     ! Print received message
     write (*, '("Fortran Model:")')
     call display_generic(obj)

     ! Print keys
     call generic_map_get_keys(obj, keys)
     write (*, '("Fortran Model: keys = ")')
     do i = 1, size(keys)
        write (*, '(A," ")', advance="no") trim(keys(i))
     end do
     write (*, '("")')

     ! Get double precision floating point element
     co2 = generic_map_get_real8(obj, "CO2")
     write (*, '("Fortran Model: CO2 = ",F10.5)') co2

     ! Get array element
     amaxtb = generic_map_get_array(obj, "AMAXTB")
     amaxtb_x => generic_array_get_1darray_real8(amaxtb, 1)
     amaxtb_y => generic_array_get_1darray_real8(amaxtb, 2)
     write (*, '("Fortran Model: AMAXTB = ")')
     do i = 1, size(amaxtb_x)
        write (*, '(A,F10.5,A,F10.5)') char(11), amaxtb_x(i), &
             char(11), amaxtb_y(i)
     end do

     ! Send output to output channel
     ! If there is an error, the flag will be false
     flag = ygg_send_var(out_channel, yggarg(obj))
     if (.not.flag) then
        write (*, '("Fortran Model: Error sending output.")')
        exit
     end if

  end do

end program main
