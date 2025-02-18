# Once done this will define
#  HDF5_FOUND - System has HDF5
#  HDF5_INCLUDE_DIRS - The HDF5 include directories
#  HDF5_LIBRARIES - The libraries needed to use HDF5
#  HDF5_DEFINITIONS - Compiler switches required for using HDF5

#set(HDF5_DIR "/sdcc/u/tzhang/soft/petsc-3.16.0//")
set(HDF5_DIR "/global/homes/p/prince93/soft/petsc-3.16.0/")
#set(HDF5_DIR "/global/homes/p/prince93/petsc-3.16.0-mpich/")
#set(HDF5_DIR "/sdcc/u/tzhang/soft/miniconda3/envs/pr-dns//")

find_path(HDF5_INCLUDE_DIR hdf5.h 
        HINTS ${HDF5_DIR}/include
		/usr/include
		/usr/local/include)

find_library(HDF5_LIBRARY NAMES hdf5
        HINTS ${HDF5_DIR}/lib
		   /usr/lib
		   /usr/lib64
		   /usr/local/lib)

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set HDF5_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(HDF5  DEFAULT_MSG
        HDF5_LIBRARY HDF5_INCLUDE_DIR)

mark_as_advanced(HDF5_INCLUDE_DIR HDF5_LIBRARY )

set(HDF5_LIBRARIES ${HDF5_LIBRARY} )
set(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR} )
