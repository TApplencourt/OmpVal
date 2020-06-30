#ifndef _OPENMP
FUNCTION omp_get_num_threads() RESULT(i)
  INTEGER :: i
  i = 1
END FUNCTION omp_get_num_threads
#endif
FUNCTION almost_equal(x, gold, tol) RESULT(b)
  implicit none
  REAL, intent(in) :: x
  INTEGER,  intent(in) :: gold
  REAL,     intent(in) :: tol
  LOGICAL              :: b
  b = ( gold * (1 - tol)  <= x ).AND.( x <= gold * (1+tol) )
END FUNCTION almost_equal
PROGRAM target_parallel__simd
#ifdef _OPENMP
  USE OMP_LIB
  implicit none
#else
  implicit none
  INTEGER :: omp_get_num_threads
#endif
  INTEGER :: N0 = 262144
  INTEGER :: i0
  LOGICAL :: almost_equal
  REAL :: counter_parallel
  INTEGER :: expected_value
  expected_value = N0
  counter_parallel = 0
  !$OMP target parallel map(tofrom: counter_parallel)
    !$OMP simd
    DO i0 = 1, N0
      !$OMP atomic update
      counter_parallel = counter_parallel + 1.  / omp_get_num_threads() ;
    END DO
  !$OMP END target parallel
  IF ( .NOT.almost_equal(counter_parallel,expected_value, 0.1) ) THEN
    WRITE(*,*)  'Expected', expected_value,  'Got', counter_parallel
    STOP 112
  ENDIF
END PROGRAM target_parallel__simd