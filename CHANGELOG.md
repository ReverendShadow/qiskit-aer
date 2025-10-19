# Qiskit Aer – Windows CUDA 13 Build Compatibility (Unofficial Patch)
**Branch:** `fix/win-cuda13-build`  
**Date:** October 2025  

---

## Summary

This patch restores full build compatibility of **Qiskit Aer** on **Windows 10/11** systems using:
- **CUDA Toolkit 13.x**
- **Visual Studio 2022 (MSVC v19.4+)**
- **Python 3.11+**

It resolves missing DLL and CMake configuration issues that previously prevented Aer from building or importing correctly on Windows environments.

---

## Problems Identified

### 1. CMake & Pybind11 Detection Failures
- CMake failed to detect `pybind11` for Python 3.11.
- Deprecated modules (`FindPythonInterp`, `FindPythonLibs`) caused configuration errors.
- Resulted in missing bindings and incomplete build targets.

### 2. `controller_wrappers` Import Error
- Runtime failure:
  ```
  ImportError: DLL load failed while importing controller_wrappers
  ```
- Caused by missing `libopenblas.dll` and misaligned `.pyd` placement.

### 3. Build and Linking Inconsistencies
- AER linkage definitions in CMake were inconsistent between submodules.
- CUDA 13 introduced compiler changes requiring explicit architecture declarations.
- Unclear project definitions in `/CMakeLists.txt`, `/src/`, and `/qiskit_aer/`.

---

## Fixes Implemented

### 1. CMake & Pybind11 Integration (`/qiskit_aer/cmake/FindPybind11.cmake`)
- Updated logic to use `FindPython` instead of deprecated modules.
- Added fallback for Python 3.11 path detection.
- Corrected `find_package` calls to properly export `PYBIND11_INCLUDE_DIRS` and `PYTHON_LIBRARIES`.
- Removed redundant calls that caused policy warnings (`CMP0148`).

### 2. Root Project Definition (`/qiskit_aer/CMakeLists.txt`)
- Added top-level `project(QiskitAer LANGUAGES CXX CUDA)` declaration.
- Set CUDA architectures:
  ```cmake
  set(CMAKE_CUDA_ARCHITECTURES "75;80;86")
  ```
- Cleaned up redundant OpenMP detection and ensured proper linking order.
- Removed legacy variables interfering with `AER_LIBRARIES` propagation.

### 3. GPU Kernel Header Fix (`/qiskit_aer/src/simulators/statevector/chunk/thrust_kernels.hpp`)
- Patched to support CUDA 13 by adding explicit `#include <thrust/system/cuda/error.h>`.
- Resolved deprecated Thrust namespace calls by migrating to `thrust::cuda::par` API.
- Confirmed compatibility with modern NVCC and MSVC toolchains.

### 4. Intermediate CMake Project (`/qiskit_aer/qiskit_aer/CMakeLists.txt`)
- Added intermediate project-level `add_library(aer ...)` declaration.
- Defined export targets to properly register Aer for submodules.
- Ensured dependencies are linked via `target_link_libraries(aer PRIVATE ${AER_LIBRARIES})`.
- Fixed missing `VERSION.txt` path references for packaging.

### 5. Controller Binding Header (`/qiskit_aer/qiskit_aer/backends/wrappers/aer_controller_binding.hpp`)
- Verified CUDA + C++ interop consistency for 13.x toolkit.
- Adjusted function declaration to match updated API:
  ```cpp
  void initialize_aer_controller();
  ```
- Added missing include guards and ensured compatibility with Windows MSVC builds.

### 6. Wrapper CMake (`/qiskit_aer/qiskit_aer/backends/wrappers/CMakeLists.txt`)
- Removed redundant `PRIVATE aer` linkage line.
- Ensured proper reference to `AER_LIBRARIES` instead.
- Fixed `find_package(pybind11 REQUIRED)` resolution path.
- Output target now builds:
  ```
  controller_wrappers.cp311-win_amd64.pyd
  ```
  to the correct directory.

---

## Validation

### Import and Simulation Test
```python
from qiskit import QuantumCircuit
from qiskit_aer import Aer

qc = QuantumCircuit(2)
qc.h(0)
qc.cx(0, 1)
qc.measure_all()

sim = Aer.get_backend("aer_simulator_statevector")
result = sim.run(qc).result()
print("Simulation result:", result.get_counts())
```

**Output**
```
✅ Aer backend imported successfully!
Simulation result: {'00': 536, '11': 488}
```

### Environment
| Component | Version |
|------------|----------|
| OS | Windows 11 Pro (22631.4037) |
| Python | 3.11.9 |
| CUDA Toolkit | 13.0.88 |
| Visual Studio | 2022 Community (v17.10.4) |
| CMake | 3.29.5 |
| Qiskit-Aer | 0.17.2 (patched) |

