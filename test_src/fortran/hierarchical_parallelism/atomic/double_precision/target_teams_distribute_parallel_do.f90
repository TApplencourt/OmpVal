

program target_teams_distribute_parallel_do


    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER = 0

    
    

     
    
    !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    

!$OMP ATOMIC UPDATE

counter = counter + 1.


 
     

    END DO

    !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON(COUNTER) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_teams_distribute_parallel_do