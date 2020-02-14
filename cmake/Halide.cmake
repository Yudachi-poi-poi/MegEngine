include(ExternalProject)
find_package(LLVM 6.0 REQUIRED CONFIG)

STRING(REPLACE "." ";" LLVM_VERSION_LIST ${LLVM_PACKAGE_VERSION})
list(GET LLVM_VERSION_LIST 0 LLVM_VERSION_MAJOR)
list(GET LLVM_VERSION_LIST 1 LLVM_VERSION_MINOR)

set(HALIDE_DIR "${PROJECT_SOURCE_DIR}/third_party/Halide" CACHE STRING "halide directory")
set(HALIDE_BUILD_DIR ${PROJECT_BINARY_DIR}/third_party/Halide)
set(HALIDE_LIB ${HALIDE_BUILD_DIR}/lib/libHalide.a)
ExternalProject_add(
    halide
    SOURCE_DIR ${HALIDE_DIR}
    PREFIX ${HALIDE_BUILD_DIR}
    CMAKE_ARGS -DCMAKE_C_COMPILER_LAUNCHER=${CMAKE_C_COMPILER_LAUNCHER} -DCMAKE_CXX_COMPILER_LAUNCHER=${CMAKE_CXX_COMPILER_LAUNCHER} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DCMAKE_INSTALL_PREFIX=${HALIDE_BUILD_DIR} -DWITH_APPS=OFF -DWITH_TESTS=OFF -DWITH_TUTORIALS=OFF -DHALIDE_SHARED_LIBRARY=OFF -DHALIDE_REQUIRE_LLVM_VERSION=${LLVM_VERSION_MAJOR}${LLVM_VERSION_MINOR} -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DTARGET_MIPS=OFF -DTARGET_POWERPC=OFF
    BUILD_BYPRODUCTS ${HALIDE_LIB}
)

set(HALIDE_INC ${HALIDE_BUILD_DIR}/include)
file(MAKE_DIRECTORY ${HALIDE_INC})
add_library(libhalide STATIC IMPORTED GLOBAL)
add_dependencies(libhalide halide)
set_target_properties(
    libhalide PROPERTIES
    IMPORTED_LOCATION ${HALIDE_LIB}
    INTERFACE_INCLUDE_DIRECTORIES ${HALIDE_INC}
)

set(LLVM_COMPONENTS mcjit;bitwriter;linker;passes;X86;ARM;AArch64;Hexagon;NVPTX;AMDGPU)
llvm_map_components_to_libnames(HALIDE_LLVM_LIBS ${LLVM_COMPONENTS})
