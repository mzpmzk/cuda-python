# Copyright 2021-2022 NVIDIA Corporation.  All rights reserved.
#
# Please refer to the NVIDIA end user license agreement (EULA) associated
# with this source code for terms and conditions that govern your use of
# this software. Any use, reproduction, disclosure, or distribution of
# this software and related documentation outside the terms of the EULA
# is strictly prohibited.
from cuda.ccudart cimport *
from libc.stdlib cimport malloc, free, calloc
from libc.string cimport memset, memcpy, strncmp
from libcpp cimport bool
cimport cuda._cuda.ccuda as ccuda

cdef class cudaPythonGlobal:
    cdef bint _cudaPythonInit
    cdef bint _cudaPythonGlobalInit
    cdef int _numDevices
    cdef ccuda.CUdevice* _driverDevice
    cdef ccuda.CUcontext* _driverContext
    cdef bool* _deviceInit
    cdef cudaDeviceProp* _deviceProperties
    cdef cudaError_t _lastError
    cdef int _CUDART_VERSION

    cdef cudaError_t lazyInit(self) nogil except ?cudaErrorCallRequiresNewerDriver
    cdef cudaError_t lazyInitGlobal(self) nogil except ?cudaErrorCallRequiresNewerDriver
    cdef cudaError_t lazyInitDevice(self, int deviceOrdinal) nogil except ?cudaErrorCallRequiresNewerDriver

cdef cudaPythonGlobal globalGetInstance()
cdef cudaError_t _setLastError(cudaError_t err) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getDescInfo(const cudaChannelFormatDesc* d, int *numberOfChannels, ccuda.CUarray_format *format) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t streamAddCallbackCommon(cudaStream_t stream, cudaStreamCallback_t callback, void *userData, unsigned int flags) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t streamGetCaptureInfoCommon(cudaStream_t stream, cudaStreamCaptureStatus* captureStatus_out, unsigned long long *id_out, cudaGraph_t *graph_out, const cudaGraphNode_t **dependencies_out, size_t *numDependencies_out) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getChannelFormatDescFromDriverDesc(cudaChannelFormatDesc* pRuntimeDesc, size_t* pDepth, size_t* pHeight, size_t* pWidth, const ccuda.CUDA_ARRAY3D_DESCRIPTOR_v2* pDriverDesc) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyFromHost2D(cudaArray_const_t thisArray, size_t hOffset, size_t wOffset, const char *src, size_t spitch, size_t width, size_t height, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyFromDevice2D(ccuda.CUmemorytype type, cudaArray_const_t thisArray, size_t hOffset, size_t wOffset, const char *src, size_t srcOffset,
                                  size_t spitch, size_t width, size_t height, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyToHost2D(cudaArray_const_t thisArray, size_t hOffset, size_t wOffset, char *dst, size_t dpitch, size_t width,
                              size_t height, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyToDevice2D(ccuda.CUmemorytype type, cudaArray_const_t thisArray, size_t hOffset, size_t wOffset, const char *dst, size_t dstOffset, size_t dpitch,
                                size_t width, size_t height, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyToArray2D(cudaArray_const_t thisArray, size_t hOffsetSrc, size_t wOffsetSrc, cudaArray_t dst,
                               size_t hOffsetDst, size_t wOffsetDst, size_t width, size_t height) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getChannelDesc(cudaArray_const_t thisArray, cudaChannelFormatDesc *outDesc) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getDriverResDescFromResDesc(ccuda.CUDA_RESOURCE_DESC *rdDst, const cudaResourceDesc *rdSrc,
                                             ccuda.CUDA_TEXTURE_DESC *tdDst, const cudaTextureDesc *tdSrc,
                                             ccuda.CUDA_RESOURCE_VIEW_DESC *rvdDst, const cudaResourceViewDesc *rvdSrc) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getResDescFromDriverResDesc(cudaResourceDesc *rdDst, const ccuda.CUDA_RESOURCE_DESC *rdSrc,
                                             cudaTextureDesc *tdDst, const ccuda.CUDA_TEXTURE_DESC *tdSrc,
                                             cudaResourceViewDesc *rvdDst, const ccuda.CUDA_RESOURCE_VIEW_DESC *rvdSrc) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memsetPtr(char *mem, int c, size_t count, cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memset2DPtr(char *mem, size_t pitch, int c, size_t width, size_t height, cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyFromHost(cudaArray_const_t thisArray, size_t hOffset, size_t wOffset, const char *src, size_t count,
                              ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyFromDevice(ccuda.CUmemorytype type, cudaArray_const_t thisArray, size_t hOffset, size_t wOffset,
                                const char *src, size_t srcOffset, size_t count, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyToHost(cudaArray_const_t thisArray, size_t hOffset, size_t wOffset, char *dst, size_t count, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copyToDevice(ccuda.CUmemorytype type, cudaArray_const_t thisArray, size_t hOffset, size_t wOffset,
                              const char *dst, size_t dstOffset, size_t count, ccuda.CUstream stream, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t copy1DConvertTo3DParams(void* dst, const void* src, size_t count, cudaMemcpyKind kind, cudaMemcpy3DParms *p) nogil except ?cudaErrorCallRequiresNewerDriver
cdef void toDriverMemsetNodeParams(const cudaMemsetParams *pRuntimeParams, ccuda.CUDA_MEMSET_NODE_PARAMS *pDriverParams) nogil
cdef cudaError_t toDriverMemCopy3DParams(const cudaMemcpy3DParms *p, ccuda.CUDA_MEMCPY3D *cd) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t mallocArray(cudaArray_t *arrayPtr, const cudaChannelFormatDesc *desc, size_t depth, size_t height,
                             size_t width, int corr2D, unsigned int flags) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpy2DToArray(cudaArray_t dst, size_t hOffset, size_t wOffset, const char *src,
                                 size_t spitch, size_t width, size_t height, cudaMemcpyKind kind,
                                 cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpyDispatch(void *dst, const void *src, size_t size, cudaMemcpyKind kind) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t mallocHost(size_t size, void **mem, unsigned int flags) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t mallocPitch(size_t width, size_t height, size_t depth, void **mem, size_t *pitch) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t mallocMipmappedArray(cudaMipmappedArray_t *mipmappedArrayPtr, const cudaChannelFormatDesc *desc,
                                      size_t depth, size_t height, size_t width, unsigned int numLevels, unsigned int flags) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpy2DPtr(char *dst, size_t dpitch, const char *src, size_t spitch, size_t width,
                             size_t height, cudaMemcpyKind kind,
                             cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpy3D(const cudaMemcpy3DParms *p, bool peer, int srcDevice, int dstDevice, cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpyAsyncDispatch(void *dst, const void *src, size_t size, cudaMemcpyKind kind, cudaStream_t stream) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t toCudartMemCopy3DParams(const ccuda.CUDA_MEMCPY3D_v2 *cd, cudaMemcpy3DParms *p) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpy2DFromArray(char *dst, size_t dpitch, cudaArray_const_t src, size_t hOffset,
                                   size_t wOffset, size_t width, size_t height, cudaMemcpyKind kind,
                                   cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpy2DArrayToArray(cudaArray_t dst, size_t hOffsetDst, size_t wOffsetDst,
                                      cudaArray_const_t src, size_t hOffsetSrc, size_t wOffsetSrc,
                                      size_t width, size_t height, cudaMemcpyKind kind) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memset3DPtr(cudaPitchedPtr p, int val, cudaExtent e, cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpyToArray(cudaArray_t dst, size_t hOffset, size_t wOffset, const char *src,
                               size_t count, cudaMemcpyKind kind,
                               cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpyFromArray(char *dst, cudaArray_const_t src, size_t hOffset, size_t wOffset,
                                 size_t count, cudaMemcpyKind kind,
                                 cudaStream_t sid, bool async) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t memcpyArrayToArray(cudaArray_t dst, size_t hOffsetDst, size_t wOffsetDst,
                                    cudaArray_const_t src, size_t hOffsetSrc, size_t wOffsetSrc,
                                    size_t count, cudaMemcpyKind kind) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t toDriverCudaResourceDesc(ccuda.CUDA_RESOURCE_DESC *_driver_pResDesc, const cudaResourceDesc *pResDesc) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getDriverEglFrame(ccuda.CUeglFrame *cuEglFrame, cudaEglFrame eglFrame) nogil except ?cudaErrorCallRequiresNewerDriver
cdef cudaError_t getRuntimeEglFrame(cudaEglFrame *eglFrame, ccuda.CUeglFrame cueglFrame) nogil except ?cudaErrorCallRequiresNewerDriver
