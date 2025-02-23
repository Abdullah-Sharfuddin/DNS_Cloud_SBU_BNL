#!/bin/bash
##SBATCH -p skydebug
##SBATCH -p sky
#SBATCH -p long
#SBATCH -A dns
#SBATCH -J dns

#SBATCH  --nodes=2
#SBATCH  --output=debug.%j
#SBATCH  --error=error.%j
#SBATCH  --exclusive
##SBATCH  --mail-type=ALL
##SBATCH  --mail-user=tzhang@bnl.gov
#SBATCH  --time=10:00:00


ulimit -s unlimited


#cd /sdcc/u/tzhang/PR_DNS_base/DNS/climate
rm -rf out-pr-dns
mpirun --mca  btl_openib_allow_ib 1 -n 64 /sdcc/u/tzhang/PR_DNS_base/DNS/climate/climate -d 3 -p 4 4 4 -i input-pr-dns/in-entrainment3dd_case1 -o out-pr-dns 
#mpirun --mca  btl_openib_allow_ib 1 -n 128 /sdcc/u/tzhang/PR_DNS_base/DNS/climate/climate -d 3 -p 8 4 4 -i input-pr-dns/in-entrainment3dd_case1 -o out-pr-dns 
#mpirun --mca  btl_openib_allow_ib 1 -n 256 /sdcc/u/tzhang/PR_DNS_base/DNS/climate/climate -d 3 -p 8 8 4 -i input-pr-dns/in-entrainment3dd_case1 -o out-pr-dns 
#mpirun --mca  btl_openib_allow_ib 1 -n 512 /sdcc/u/tzhang/PR_DNS_base/DNS/climate/climate -d 3 -p 8 8 8 -i input-pr-dns/in-entrainment3dd_case1 -o out-pr-dns 
