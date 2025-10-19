# qiskit_aer/CMakeLists.txt
# Create a stub "aer" library so controller_wrappers can link against it.

add_library(aer INTERFACE)

target_include_directories(aer INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link any required system or third-party libraries
target_link_libraries(aer INTERFACE
    ${AER_LIBRARIES}
    OpenMP::OpenMP_CXX
)