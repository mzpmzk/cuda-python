try:
    import cupy as cp
except ImportError:
    cp = None
try:
    from numba import cuda as numba_cuda
except ImportError:
    numba_cuda = None
import numpy as np
import pytest

from cuda.core.experimental import Device
from cuda.core.experimental.utils import StridedMemoryView, viewable


def convert_strides_to_counts(strides, itemsize):
    return tuple(s // itemsize for s in strides)


@pytest.mark.parametrize(
    "in_arr,", (
        np.empty(3, dtype=np.int32),
        np.empty((6, 6), dtype=np.float64)[::2, ::2],
        np.empty((3, 4), order='F'),
    )
)
def test_viewable_cpu(in_arr):

    @viewable((0,))
    def my_func(arr):
        view = arr.view(-1)
        assert isinstance(view, StridedMemoryView)
        assert view.ptr == in_arr.ctypes.data
        assert view.shape == in_arr.shape
        strides_in_counts = convert_strides_to_counts(
            in_arr.strides, in_arr.dtype.itemsize)
        if in_arr.flags.c_contiguous:
            assert view.strides is None
        else:
            assert view.strides == strides_in_counts
        assert view.dtype == in_arr.dtype
        assert view.device_id == 0
        assert view.device_accessible == False
        assert view.exporting_obj is in_arr

    my_func(in_arr)


def gpu_array_samples():
    # TODO: this function would initialize the device at test collection time
    samples = []
    if cp is not None:
        samples += [
            (cp.empty(3, dtype=cp.complex64), None),
            (cp.empty((6, 6), dtype=cp.float64)[::2, ::2], True),
            (cp.empty((3, 4), order='F'), True),
        ]
    # Numba's device_array is the only known array container that does not
    # support DLPack (so that we get to test the CAI coverage).
    if numba_cuda is not None:
        samples += [
            (numba_cuda.device_array((2,), dtype=np.int8), None),
            (numba_cuda.device_array((4, 2), dtype=np.float32), True),
        ]
    return samples


def gpu_array_ptr(arr):
    if cp is not None and isinstance(arr, cp.ndarray):
        return arr.data.ptr
    if numba_cuda is not None and isinstance(arr, numba_cuda.cudadrv.devicearray.DeviceNDArray):
        return arr.device_ctypes_pointer.value
    assert False, f"{arr=}"


@pytest.mark.parametrize(
    "in_arr,stream", (
        *gpu_array_samples(),
    )
)
def test_viewable_gpu(in_arr, stream):
    # TODO: use the device fixture?
    dev = Device()
    dev.set_current()
    s = dev.create_stream() if stream else None

    @viewable((0,))
    def my_func(arr):
        view = arr.view(s.handle if s else -1)
        assert isinstance(view, StridedMemoryView)
        assert view.ptr == gpu_array_ptr(in_arr)
        assert view.shape == in_arr.shape
        strides_in_counts = convert_strides_to_counts(
            in_arr.strides, in_arr.dtype.itemsize)
        if in_arr.flags["C_CONTIGUOUS"]:
            assert view.strides in (None, strides_in_counts)
        else:
            assert view.strides == strides_in_counts
        assert view.dtype == in_arr.dtype
        assert view.device_id == dev.device_id
        assert view.device_accessible == True
        assert view.exporting_obj is in_arr

    my_func(in_arr)
