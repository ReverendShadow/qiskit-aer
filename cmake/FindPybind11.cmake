# Modern pybind11 finder for Qiskit Aer
find_package(pybind11 CONFIG REQUIRED)
if (NOT pybind11_FOUND)
    message(FATAL_ERROR "pybind11 not found. Install via `pip install pybind11[global]`.")
else()
    message(STATUS "Found pybind11: ${pybind11_DIR}")
endif()
# Modern pybind11 finder for Qiskit Aer
find_package(pybind11 CONFIG REQUIRED)
if (NOT pybind11_FOUND)
    message(FATAL_ERROR "pybind11 not found. Install via `pip install pybind11[global]`.")
else()
    message(STATUS "Found pybind11: ${pybind11_DIR}")
endif()
