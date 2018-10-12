##===-------------------------------------------------------------------------------------------===##
##                        _..._                                                          
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(yodaIncludeGuard)
yoda_include_guard()

include(yodaAddExecutable)

#.rst:
# yoda_add_unittest
# ----------------------------
#
# Compile the given objects into a runnable unittest executable (.exe) and register it within CTest.
# Note that to enable CTest you need to call the builtin command ``enable_testing()`` in the source 
# root.
#
# .. code-block:: cmake
#
#   yoda_add_unittest(NAME SOURCES DEPENDS [OUTPUT_DIR GTEST_ARGS])
#
# ``NAME``
#   Name of the unittest exectuable as well as the CMake target to build it.
# ``SOURCES``
#   List of source files making up the exectuable.
# ``DEPENDS``
#   List of external libraries and/or CMake targets to link against.
# ``OUTPUT_DIR`` [optional]
#   Directory to place the exectuable (e.g ``${CMAKE_BINARY_DIR}/bin``).
# ``GTEST_ARGS`` [optional]
#   Arguments passed to the created GTest exectuable (e.g ``--gtest_color=yes``)
# ``LIBRARIES`` 
#   List of external libraries and/or CMake targets to link against. 
# ``DEPENDS`` 
#   List of cmake targets the executable depends on 
# ``INSTALL_DESTINATION`` [optional] 
#   Destition (relative to ``CMAKE_INSTALL_PREFIX``) to install the executable.
# ``INCLUDE_DIRECTORIES`` [optional]
#   include directories for compilaton
function(yoda_add_unittest)
  set(one_value_args NAME OUTPUT_DIR INSTALL_DESTINATION)
  set(multi_value_args SOURCES DEPENDS LIBRARIES INCLUDE_DIRECTORIES GTEST_ARGS)
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "yoda_add_unittest: invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  yoda_require_arg("NAME" ${ARG_NAME})
  yoda_require_arg("SOURCES" ${ARG_SOURCES})

  set(opt_arg)
  if(ARG_DEPENDS)
    set(opt_arg ${opt_arg} DEPENDS ${ARG_DEPENDS})
  endif()
  if(ARG_OUTPUT_DIR)
    set(opt_arg ${opt_arg} OUTPUT_DIR ${ARG_OUTPUT_DIR})
  endif()
  if(ARG_LIBRARIES)
    set(opt_arg ${opt_arg} LIBRARIES ${ARG_LIBRARIES})
  endif() 
  if(ARG_INCLUDE_DIRECTORIES)
    set(opt_arg ${opt_arg} INCLUDE_DIRECTORIES ${ARG_INCLUDE_DIRECTORIES})
  endif()
  if(ARG_INSTALL_DESTINATION)
    set(opt_arg ${opt_arg} INSTALL_DESTINATION ${ARG_INSTALL_DESTINATION})
  endif()

  yoda_add_executable(
    NAME ${ARG_NAME} 
    SOURCES ${ARG_SOURCES} 
    ${opt_arg}
  )  

  add_test(NAME CTest-${ARG_NAME} COMMAND $<TARGET_FILE:${ARG_NAME}> ${ARG_GTEST_ARGS})
endfunction()
