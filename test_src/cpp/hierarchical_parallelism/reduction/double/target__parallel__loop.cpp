#include <iostream>
#include <limits>
#include <cmath>




bool almost_equal(double x, double y, int ulp) {

     return std::fabs(x-y) <= std::numeric_limits<double>::epsilon() * std::fabs(x+y) * ulp ||  std::fabs(x-y) < std::numeric_limits<double>::min();

}



void test_target__parallel__loop.cpp(){

 // Input and Outputs
 
 const int L = 5;

double counter{};

// Main program

#pragma omp target   map(tofrom:counter) 

{


#pragma omp parallel  reduction(  +  :counter)  

{


#pragma omp loop  reduction(  +  :counter)  

    for (int i = 0 ; i < L ; i++ )

{




counter += double { 1.0f };



}

}

}


// Validation
if ( !almost_equal(counter,double { L }, 10)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    throw std::runtime_error( "target__parallel__loop.cpp give incorect value when offloaded");
}

}
int main()
{
    test_target__parallel__loop.cpp();
}