#!/bin/bash

#SBATCH --account=m4402
#SBATCH --constraint=cpu
#SBATCH --qos=regular
#SBATCH --time=48:00:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=128

export PATH=/global/homes/p/prince93/soft/petsc-3.16.0/lib/petsc/bin/:$PATH

##srun -n 128 ./climate -d 3 -p 8 4 4 -i ./input-pr-dns/in-entrainment3dd_caseS22 -o $PSCRATCH/output_caseL2 |& tee srun.log
srun -n 512 ./climate -d 3 -p 8 8 8 -i ./input-pr-dns/in-entrainment3dd_caseS13 -o $PSCRATCH/output_caseA |& tee srun.log
##srun -n 128 ./climate -d 3 -p 8 4 4 -i ./input-pr-dns/in-entrainment3dd_caseS11 -o $PSCRATCH/output_caseA_128 |& tee srun.log
