# GMXPlumed


## Software versions
* Gromacs v2018.4
* Plumed v2.5.0
* CUDA v10.0
* Ubuntu v16.04

## Notes
Gromacs is configured to use AVX2_256 instructions and will therefore run only on newest Intel hardware. MPI is enabled for PLUMED, while Gromacs is compiled with gcc with OpenMP threading only.