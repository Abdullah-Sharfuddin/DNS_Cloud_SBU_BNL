#PBS -q batch
#PBS -l nodes=1:ppn=64
#PBS -l walltime=960:00:00
#PBS -j oe
#PBS -N DNS
#PBS -o /home/tzhang/tmp/$PBS_JOBID.out

ulimit -s unlimited

source /home/tzhang/.zshrc
export LD_LIBRARY_PATH=/software/openmpi/1.6.5-intel/lib:/software/hdf4/hdf4/lib:$LD_LIBRARY_PATH

cd /gscr2/tzhang/DNS/climate/
/software/openmpi/1.6.5-intel/bin/mpirun  --mca btl openib,self  -np 4 ./climate -d 2 -p 2 2 -i input-entrainment/in-entrainment2dm -o ./out-test

