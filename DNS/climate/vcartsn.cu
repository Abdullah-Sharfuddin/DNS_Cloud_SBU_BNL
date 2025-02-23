
#include "climate.h"

//#include <cstudio>
#include <iostream>

#include <cuda_runtime.h>


using namespace std;



#ifdef __CUDA__

//#define PI 3.14159265359


//*
//#if __CUDA_ARCH__ < 600
__device__ double atomicAddN(double* address, double val)
{
    unsigned long long int* address_as_ull =
                              (unsigned long long int*)address;
    unsigned long long int old = *address_as_ull, assumed;

    do {
        assumed = old;
        old = atomicCAS(address_as_ull, assumed,
                        __double_as_longlong(val +
                               __longlong_as_double(assumed)));

    // Note: uses integer comparison to avoid hang in case of NaN (since NaN != NaN)
    } while (assumed != old);

    return __longlong_as_double(old);
}
//#endif
//*/



void VCARTESIAN::initDevice() {
    
  cout << "[CUDA] : VCARTESIAN::initDevice() CALLED!!!" << endl;


  cudaError_t ierr;

  initFlg = 1; // initialization status;

  int count;
  int myid = pp_mynode();

  ierr = cudaGetDeviceCount(&count);
  cout << "[CUDA] : VCARTESIAN::initDevice() : Device Count : " << count << endl;
  cout << "[CUDA] : VCARTESIAN::initDevice() : Num Nodes : " << pp_numnodes() << endl;
  cout << "[CUDA] : VCARTESIAN::initDevice() : My ID : " << myid << endl;

  ierr = cudaSetDevice(myid);


  max_num_particle = 100000000; // 100 M

  //particle_buffer = new double[max_num_particle*5]; // radius, x,y,z, rho 
  ierr = cudaMallocHost((void**)&particle_buffer, 5*max_num_particle*sizeof(double));
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::initDevice() Error!!! : cudaMallocHost(particle_buffer) : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }
  ierr = cudaMalloc((void**)&particle_buffer_D, 5*max_num_particle*sizeof(double));
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::initDevice() Error!!! : cudaMalloc(particle_buffer_D) :" << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }

  max_comp_size = 100000000; // 100 M
  ierr = cudaMalloc((void**)&source_D, max_comp_size*sizeof(double));
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::initDevice() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }
  ierr = cudaMalloc((void**)&drops_D, max_comp_size*sizeof(double));
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::initDevice() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }
  ierr = cudaMalloc((void**)&cloud_D, max_comp_size*sizeof(double));
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::initDevice() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }
  ierr = cudaMalloc((void**)&supersat_D, max_comp_size*sizeof(double));
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::initDevice() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }

}

void VCARTESIAN::cleanDevice() {
  cudaFree(supersat_D);
  cudaFree(cloud_D);
  cudaFree(drops_D);
  cudaFree(source_D);
  cudaFree(particle_buffer_D);
  //delete[] particle_buffer;
  cudaFree(particle_buffer);
}

void VCARTESIAN::initOutput() {
  cudaMemset((void*)source_D, 0, sizeof(double)*comp_size);
  cudaMemset((void*)drops_D, 0, sizeof(double)*comp_size);
  cudaMemset((void*)cloud_D, 0, sizeof(double)*comp_size);
}

void VCARTESIAN::uploadParticle() {
  //cout << "[CUDA] : VCARTESIAN::uploadParticle() CALLED!!!" << endl;
  cudaError_t ierr;

  PARTICLE* particles = eqn_params->particle_array;
  int num_particles = eqn_params->num_drops;

  double* radius = particle_buffer;
  double* x = particle_buffer + num_particles;
  double* y = particle_buffer + 2*num_particles;
  double* z = particle_buffer + 3*num_particles;
  double* rho = particle_buffer + 4*num_particles;

  for(int i=0 ; i<num_particles ; i++) {
    radius[i] = particles[i].radius;
    x[i] = particles[i].center[0];
    y[i] = particles[i].center[1];
    z[i] = particles[i].center[2];
    rho[i] = particles[i].rho;
  }


  ierr = cudaMemcpy(particle_buffer_D, particle_buffer, 5*num_particles*sizeof(double), cudaMemcpyHostToDevice);
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::uploadParticle() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }


}

void VCARTESIAN::uploadSupersat() {

  //cout << "[CUDA] : VCARTESIAN::uploadSupersat() CALLED!!!" << endl;

  cudaError_t ierr = cudaMemcpy(supersat_D, eqn_params->field->supersat, comp_size*sizeof(double), cudaMemcpyHostToDevice);
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::uploadParticle() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }



}



__global__ void computeDropsInCell(int num_drops, double* particles, double* supersat, double* source, double* drops, double* cloud, double topLx, double topLy, double topLz, double tophx, double tophy, double tophz, int gmax0, int gmax1, double K, double rho_a) {

  register int i = blockIdx.x * blockDim.x + threadIdx.x;

  if(i < num_drops) {
    double radius = particles[i];
    double x = particles[i + num_drops];
    double y = particles[i + 2*num_drops];
    double z = particles[i + 3*num_drops];
    double rho = particles[i + 4*num_drops];

    double icx = floor((x - topLx + 0.5*tophx)/tophx);
    double icy = floor((y - topLy + 0.5*tophy)/tophy);
    double icz = floor((z - topLz + 0.5*tophz)/tophz);

    int index = (icz*(gmax1 + 1)+icy) * (gmax0 + 1) + icx;

    double src = (-4000.0*PI*rho*K/rho_a)*supersat[index]*radius;
    double cld = (4.0/3.0)*PI*pow(radius, 3.0)*rho/rho_a;

    atomicAdd(&source[index], src);
    //if(radius > 0) {
      atomicAdd(&drops[index], 1.0);
      atomicAdd(&cloud[index], cld);
    //}

  }



}


__global__ void computeTemperatureSource_Kernel(int num_drops, double* particles, double* supersat, double* source, double topLx, double topLy, double topLz, double tophx, double tophy, double tophz, int gmax0, int gmax1, double K, double rho_a, double lcp) {

  register int i = blockIdx.x * blockDim.x + threadIdx.x;

  if(i < num_drops) {
    double radius = particles[i];
    double x = particles[i + num_drops];
    double y = particles[i + 2*num_drops];
    double z = particles[i + 3*num_drops];
    double rho = particles[i + 4*num_drops];

    double icx = floor((x - topLx + 0.5*tophx)/tophx);
    double icy = floor((y - topLy + 0.5*tophy)/tophy);
    double icz = floor((z - topLz + 0.5*tophz)/tophz);

    int index = (icz*(gmax1 + 1)+icy) * (gmax0 + 1) + icx;

    double src = (lcp*4.0*PI*rho*K/rho_a)*supersat[index]*radius;

    atomicAdd(&source[index], src);

  }



}





void VCARTESIAN::computeVaporSource_DropsInCell(int gmax0, int gmax1, double rho_0, double a3) {

    //cout << "[CUDA] VCARTESIAN::computeVaporSource_DropsInCell() CALLED!!!" << endl;
    int num_drops = eqn_params->num_drops;

    int threads = 1024;
    int blocks = num_drops/threads + (num_drops%threads ? 1 : 0);

    cout << "[CUDA] VCARTESIAN::computeVaporSource_DropsInCell() : blocks=" << blocks << endl;

    computeDropsInCell<<<blocks, threads>>>(num_drops, particle_buffer_D, supersat_D, source_D, drops_D, cloud_D, top_L[0], top_L[1], top_L[2], top_h[0], top_h[1], top_h[2], gmax0, gmax1, eqn_params->K, rho_0*a3);
    cudaDeviceSynchronize();

    cudaError_t ierr = cudaGetLastError();
    if(cudaSuccess != ierr) {
      cout << "[CUDA] : VCARTESIAN::computeVaporSource_DropsInCell() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
    }

}


void VCARTESIAN::retrieveResult(double* source, double* drops, double* cloud) {

  cudaError_t ierr = cudaMemcpy(source, source_D, comp_size*sizeof(double), cudaMemcpyDeviceToHost);
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::retrieveResult() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }

  ierr = cudaMemcpy(drops, drops_D, comp_size*sizeof(double), cudaMemcpyDeviceToHost);
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::retrieveResult() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }

  ierr = cudaMemcpy(cloud, cloud_D, comp_size*sizeof(double), cudaMemcpyDeviceToHost);
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::retrieveResult() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }

}










void VCARTESIAN::computeVaporSource_CUDA(int num_drops, PARAMS* eqn_params, int gmax0, int gmax1, double rho_0, double a3, double lcp) {

    int threads = 1024;
    int blocks = num_drops/threads + (num_drops%threads ? 1 : 0);

    cout << "[CUDA] VCARTESIAN::computeVaporSource_DropsInCell() : blocks=" << blocks << endl;

    computeTemperatureSource_Kernel<<<blocks, threads>>>(num_drops, particle_buffer_D, supersat_D, source_D, top_L[0], top_L[1], top_L[2], top_h[0], top_h[1], top_h[2], gmax0, gmax1, eqn_params->K, rho_0*a3, lcp);
    cudaDeviceSynchronize();

    cudaError_t ierr = cudaGetLastError();
    if(cudaSuccess != ierr) {
      cout << "[CUDA] : VCARTESIAN::computeVaporSource_DropsInCell() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
    }



}


void VCARTESIAN::retrieveSource(double* source) {

  cudaError_t ierr = cudaMemcpy(source, source_D, comp_size*sizeof(double), cudaMemcpyDeviceToHost);
  if(cudaSuccess != ierr) {
    cout << "[CUDA] : VCARTESIAN::retrieveResult() Error!!! : " << ierr << ", " << cudaGetErrorString(ierr) << endl;
  }
}






#endif




