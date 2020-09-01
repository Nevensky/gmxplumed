# GMXPlumed
[![](https://images.microbadger.com/badges/version/nevensky/gmxplumed:latest-gpu.svg)](https://microbadger.com/images/nevensky/gmxplumed:latest-gpu) [![](https://img.shields.io/docker/pulls/nevensky/gmxplumed.svg)](https://hub.docker.com/r/nevensky/gmxplumed) ![](https://img.shields.io/microbadger/image-size/nevensky/gmxplumed/latest-gpu.svg) ![](https://img.shields.io/microbadger/layers/nevensky/gmxplumed/latest-gpu.svg) [![](https://img.shields.io/github/last-commit/nevensky/gmxplumed.svg)](https://github.com/Nevensky/gmxplumed/commits) [![](https://img.shields.io/github/issues-raw/nevensky/gmxplumed.svg)](https://github.com/Nevensky/gmxplumed/issues) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/6694f313a51f4330a983d66910514977)](https://www.codacy.com/app/Nevensky/gmxplumed?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Nevensky/gmxplumed&amp;utm_campaign=Badge_Grade)

## Software versions
*   Gromacs v2019.6
*   Plumed v2.6.1
*   CUDA v10.0
*   Ubuntu v16.04

## Notes
Gromacs is configured to use AVX2_256 instructions and will therefore run only on newest Intel hardware. MPI is enabled for PLUMED, while Gromacs is compiled with gcc with OpenMP threading only.
