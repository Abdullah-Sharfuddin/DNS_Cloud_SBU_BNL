module load openmpi/4.0.2

# 1. install petsc-3.16.0

- wget [https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.16.0.tar.gz](https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.16.0.tar.gz)
- tar zxvf [petsc-3.16.0.tar.gz](https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.16.0.tar.gz)
- cd petsc-petsc-3.16.0
- ./configure --CC=mpicc --CXX=mpic++ --FC=mpifort --prefix=/global/homes/z/zhangtao/soft/petsc-3.16.0  --download-fblaslapack=1 --download-make=1 --download-hdf5=1 --download-hypre=1 --with-shared-libraries --enable-static
- make -j8; make install

# 2. install other packages by conda

- conda create -n pr-dns
- conda activate pr-dns
- conda install -c eumetsat fftw3
- conda install -c conda-forge libgd
- conda install -c conda-forge hdf4

# 3. config these package paths in DNS/cmake-modules

- FindHDF4.cmake:
    - line 67: set(HDF4_DIR "/sdcc/u/tzhang/soft/miniconda3/envs/pr-dns//")
- FindHDF5.cmake:
    - line 7: set(HDF5_DIR "/sdcc/u/tzhang/soft/petsc-3.16.0//")
- FindPETSc.cmake:
    - line 16: set(PETSC_DIR "/sdcc/u/tzhang/soft/petsc-3.16.0/")

# 4. compile DNS

- ./clean.sh
- cmake -DCMAKE_CXX_COMPILER=mpic++ -DCMAKE_C_COMPILER=mpicc .
- make -j8

# 5. run DNS

- cd climate
- salloc or sbatch
- mpirun -n 64 /global/cscratch1/sd/zhangtao/PR_DNS_base/DNS/climate/climate -d 3 -p 4 4 4 -i input-pi-chamber/in-control-shorter -o out-control-shorter
- outputs are in out-control-shorter
