#include <iostream>
#include <limits>
#include <cmath>




#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams() {return 1;}
int omp_get_num_threads() {return 1;}
#endif


bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}

void test_target__teams__parallel__loop.cpp(){

 // Input and Outputs
 
 const int L = 5;

double counter{};

// Main program

#pragma omp target  map(tofrom:counter) 

{


#pragma omp teams 

{

const int num_teams = omp_get_num_teams();


#pragma omp parallel 

{


#pragma omp loop 

    for (int i = 0 ; i < L ; i++ )

{



#pragma omp atomic update

counter += double { 1.0f } / num_teams  ;



}

}

}

}


// Validation
if ( !almost_equal(counter,double { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__teams__parallel__loop.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target__teams__parallel__loop.cpp();
}