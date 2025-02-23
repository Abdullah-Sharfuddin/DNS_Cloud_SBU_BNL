#include <stdio.h>
#include "climate.h"
#include "cuda_runtime.h"

__global__ void cuda_hello(){
    printf("Hello World from GPU!\n");
}

void call_cuda() {
    int deviceCount = 0;
    cudaError_t error = cudaGetDeviceCount(&deviceCount);
    printf("number of gpus: %d\n", deviceCount);
    cuda_hello<<<1,1>>>(); 
}
