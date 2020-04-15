

program target_parallel_do


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    
    DOUBLE PRECISION :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET PARALLEL DO   REDUCTION(+:COUNTER)   MAP(TOFROM: COUNTER) 


    DO i = 1 , L 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END TARGET PARALLEL DO
    

    IF  ( ( ABS(COUNTER - L) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L Got', COUNTER
        call exit(1)
    ENDIF

end program target_parallel_do