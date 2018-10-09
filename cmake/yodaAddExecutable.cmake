##===-------------------------------------------------------------------------------------------===##
##                        _..._                                                          
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(yodaIncludeGuard)
yoda_include_guard()

include(CMakeParseArguments)

#.rst:
# yoda_add_executable
# --------------------------
#
# Compile the given objects into a runnable executable (.exe).
#
# .. code-block:: cmake
#
#   yoda_add_executable(NAME SOURCES DEPENDS [OUTPUT_DIR])
#
# ``NAME``
#   Name of the exectuable as well as the CMake target to build it.
# ``SOURCES``
#   List of source files making up the exectuable.
# ``LIBRARIES``
#   List of external libraries and/or CMake targets to link against.
# ``DEPENDS``
#   List of cmake targets the executable depends on
# ``OUTPUT_DIR`` [optional]
#   Directory to place the exectuable (e.g ``${CMAKE_BINARY_DIR}/bin``).
# ``INSTALL_DESTINATION`` [optional]
#   Destition (relative to ``CMAKE_INSTALL_PREFIX``) to install the executable.
# ``INCLUDE_DIRECTORIES`` [optional]
#   include directories for compilaton
#
function(yoda_add_executable)
  set(one_value_args NAME OUTPUT_DIR INSTALL_DESTINATION)
  set(multi_value_args SOURCES DEPENDS LIBRARIES INCLUDE_DIRECTORIES)
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "yoda_add_executable: invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  
  yoda_require_arg("NAME" ${ARG_NAME})
  yoda_require_arg("SOURCES" ${ARG_SOURCES})

  add_executable(${ARG_NAME} ${ARG_SOURCES})
  if(ARG_DEPENDS OR ARG_LIBRARIES)
    target_link_libraries(${ARG_NAME} ${ARG_DEPENDS} ${ARG_LIBRARIES})
  endif()

  if(ARG_INCLUDE_DIRECTORIES)
    target_include_directories(${ARG_NAME} PRIVATE ${ARG_INCLUDE_DIRECTORIES})
  endif()

  if(ARG_OUTPUT_DIR)
    set_target_properties(${ARG_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${ARG_OUTPUT_DIR}")
  endif()

  if(ARG_INSTALL_DESTINATION)
    install(TARGETS ${ARG_NAME} 
            DESTINATION ${ARG_INSTALL_DESTINATION} 
            EXPORT ${ARG_NAME}Targets)
  endif()
endfunction()
