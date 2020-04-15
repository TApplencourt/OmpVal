

program target__teams_loop__parallel_do


    

    implicit none
  
    INTEGER :: L = 5
    INTEGER :: i
    INTEGER :: M = 6
    INTEGER :: j
    
    REAL :: COUNTER =  0   

    
    
     
    
    !$OMP TARGET    MAP(TOFROM: COUNTER) 



    

    
    !$OMP TEAMS LOOP   REDUCTION(+:COUNTER)  


    DO i = 1 , L 


    

    
    !$OMP PARALLEL DO   REDUCTION(+:COUNTER)  


    DO j = 1 , M 


    

    


counter = counter +  1.  

 
     

    END DO

    !$OMP END PARALLEL DO
     

    END DO

    !$OMP END TEAMS LOOP
     

    !$OMP END TARGET
    

    IF  ( ( ABS(COUNTER - L*M) ) > 10*EPSILON( COUNTER   ) ) THEN
        write(*,*)  'Expected L*M Got', COUNTER
        call exit(1)
    ENDIF

end program target__teams_loop__parallel_do