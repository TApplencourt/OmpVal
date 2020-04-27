#include <iostream>
#include <cstdlib>
#include <cmath>
#include <complex>
using namespace std;
#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_num_teams()   {return 1;}
int omp_get_num_threads() {return 1;}
#endif
bool almost_equal(complex<double> x, complex<double> gold, float tol) {
        return abs(gold) * (1-tol) <= abs(x) && abs(x) <= abs(gold) * (1 + tol);
}
#pragma omp declare reduction(+: complex<double>:   omp_out += omp_in)
void test_target_teams__parallel__for(){
 const int L = 262144;
 complex<double> counter{};
#pragma omp target teams  reduction(+: counter)   map(tofrom:counter) 
{
const int num_teams = omp_get_num_teams();
#pragma omp parallel  reduction(+: counter)  
{
#pragma omp for  
    for (int i = 0 ; i < L ; i++ )
{
counter += complex<double> { 1.0f/num_teams } ;
    }
    }
    }
if ( !almost_equal(counter,complex<double> { L }, 0.1)  ) {
    std::cerr << "Expected: " << L << " Got: " << counter << std::endl;
    std::exit(112);
}
}
int main()
{
    test_target_teams__parallel__for();
}
