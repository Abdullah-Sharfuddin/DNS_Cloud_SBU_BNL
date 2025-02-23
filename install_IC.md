
# 1. select mpi-4.1.1 [openmpi/3.1.1-gnu(default) does not work, dns has the segmentation error].

- wget [https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz](https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz)
- tar zxvf [openmpi-4.1.1.tar.gz](https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz)
- cd openmpi-4.1.1
- ./configure --prefix=/sdcc/u/tzhang/soft/openmpi-4.1.1
- make -j8; make install
- add mpi environment in /.bashrc:
    - export PATH=/sdcc/u/tzhang/soft/openmpi-4.1.1/bin:$PATH
    - export LD_LIBRARY_PATH=/sdcc/u/tzhang/soft/openmpi-4.1.1/lib:$LD_LIBRARY_PATH

# 2. install petsc-3.16.0

- wget [https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.16.0.tar.gz](https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.16.0.tar.gz)
- tar zxvf [petsc-3.16.0.tar.gz](https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.16.0.tar.gz)
- cd petsc-petsc-3.16.0
- ./configure --CC=mpicc --CXX=mpic++ --FC=mpifort --prefix=/sdcc/u/tzhang/soft/petsc-3.16.0 --download-fblaslapack=1 --download-make=1 --download-hdf5=1 --download-hypre=1 --with-shared-libraries --enable-static
- make -j8; make install

# 3. install other packages by conda

- conda create -n pr-dns
- conda activate pr-dns
- conda install -c eumetsat fftw3
- conda install -c conda-forge libgd
- conda install -c conda-forge hdf4

# 4. config these package paths in DNS/cmake-modules

- FindHDF4.cmake:
    - line 67: set(HDF4_DIR "/sdcc/u/tzhang/soft/miniconda3/envs/pr-dns//")
- FindHDF5.cmake:
    - line 7: set(HDF5_DIR "/sdcc/u/tzhang/soft/petsc-3.16.0//")
- FindPETSc.cmake:
    - line 16: set(PETSC_DIR "/sdcc/u/tzhang/soft/petsc-3.16.0/")

# 5. compile DNS

- ./clean.sh
- cmake -DCMAKE_CXX_COMPILER=mpic++ -DCMAKE_C_COMPILER=mpicc .
- make -j8

# 6. run DNS

- cd climate
- sbatch run_DNS_3d.sh
- outputs are in out-control-shorter



