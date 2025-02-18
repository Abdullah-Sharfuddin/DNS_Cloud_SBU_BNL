#!/bin/bash

#SBATCH --account=m4402
#SBATCH --constraint=cpu
#SBATCH --qos=regular
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128

export PATH=/global/homes/p/prince93/soft/petsc-3.16.0/lib/petsc/bin/:$PATH

#srun -n 1 ./climate/climate -d 3 -p 1 1 1 -i ./climate/input-pr-dns/in-entrainment3dd_case1 -o $PSCRATCH/out-mpich-256x256x256-4x2x2-prnds-w  |& tee srun.log

srun -n 128 ./climate -d 3 -p 8 4 4 -i ./input-pr-dns/in-entrainment3dd_caseSS2 -o $PSCRATCH/output-entrainment3dd_caseJ2_128 |& tee srun.log
##srun -n 32 ./climate -d 3 -p 4 4 2 -i ./input-pr-dns/in-entrainment3dd_caseS11 -o $PSCRATCH/output-entrainment3dd_caseC1_64 |& tee srun.log
##srun -n 32 ./climate -d 3 -p 4 4 2 -i ./input-pr-dns/in-entrainment3dd_caseS2 -o $PSCRATCH/output-entrainment3dd_caseC2_64 |& tee srun.log
##srun -n 512 ./climate -d 3 -p 8 8 8 -i ./input-pr-dns/in-entrainment3dd_caseS13 -o $PSCRATCH/output-entrainment3dd_caseC1_512 |& tee srun.log
##srun -n 512 ./climate -d 3 -p 8 8 8 -i ./input-pr-dns/in-entrainment3dd_caseS22 -o $PSCRATCH/output-entrainment3dd_caseA2_256 |& tee srun.log
##srun -n 1 ./climate -d 3 -p 1 1 1 -i ./input-pr-dns/in-entrainment3dd_caseS11 -o $PSCRATCH/output-entrainment3dd_caseC1S |& tee srun.log
