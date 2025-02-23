# 1. include the cuda package:
  module add cuda/11.1

# 2. PR_DNS_base/DNS/CMakeLists.txt:
  project (climate C CXX CUDA)

# 3. PR_DNS_base/DNS/climate/CMakeLists.txt
  file(GLOB climate_source "*.cpp" "*.h" "*.cu")

# 4. test the cuda demo code
  testgpu.cu

# 5. call the cuda function in vcartsn.cpp:
  call_cuda();

# 6. add the function prototype in the climate.h:
  extern void call_cuda();

# 7. configuration:
  cmake  -DCMAKE_CXX_COMPILER=mpic++ -DCMAKE_C_COMPILER=mpicc .

# 8. complile:
  make -j8
