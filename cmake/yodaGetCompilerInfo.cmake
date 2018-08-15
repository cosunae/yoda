##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(yodaIncludeGuard)
yoda_include_guard()

#.rst:
# msbuid_get_compiler_info
# ------------------------
#
# Get the identification string of the compiler.
#
# .. code-block:: cmake
#
#   yoda_get_compiler()
#
# The functions defines the following variable:
#
# ``YODA_COMPILER_STRING``
#   String of the currently used compiler.
# 
# and conditionally one of the following:
#
# ``YODA_COMPILER_MSVC``
#   Set to 1 if the compiler in use is MSVC
# ``YODA_COMPILER_GNU``
#   Set to 1 if the compiler in use is GNU
# ``YODA_COMPILER_CLANG``
#   Set to 1 if the compiler in use is Clang
#
macro(yoda_get_compiler_info)
  if("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")
    set(YODA_COMPILER_MSVC 1 CACHE INTERNAL "Compiler is MSVC" FORCE)
    set(YODA_COMPILER_STRING "Visual Studio (${CMAKE_CXX_COMPILER_VERSION})" 
        CACHE INTERNAL "Compiler-id string" FORCE)
  elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
    set(YODA_COMPILER_GNU 1 CACHE INTERNAL "Compiler is GNU gcc" FORCE)
    set(YODA_COMPILER_STRING "GNU gcc (${CMAKE_CXX_COMPILER_VERSION})" 
        CACHE INTERNAL "Compiler-id string" FORCE)
  elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    set(YODA_COMPILER_CLANG 1 CACHE INTERNAL "Compiler is LLVM Clang" FORCE)
    set(YODA_COMPILER_STRING "LLVM Clang (${CMAKE_CXX_COMPILER_VERSION})" 
        CACHE INTERNAL "Compiler-id string" FORCE)
  else()
    ## TODO add support for fortran compiler
    set(YODA_COMPILER_STRING "unknown" CACHE INTERNAL  "" FORCE)
  endif()
endmacro()
