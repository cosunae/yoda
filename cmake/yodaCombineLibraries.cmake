##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(yodaIncludeGuard)
yoda_include_guard()

include(CMakeParseArguments)
include(yodaRequireArg)

#.rst:
# yoda_combine_libraries
# -----------------------------------
#
# Combine multiple object libraries to a single static and, if ``BUILD_SHARED_LIBS`` is ON, shared 
# library. The CMake target of the library is ``<NAME>Static`` and ``<NAME>Shared`` respectively.
# This will also provide an install traget for the libraries as well as an export via 
# ``<NAME>Targets``.
#
# .. code-block:: cmake
#
#   yoda_combine_libraries(NAME OBJECTS DEPENDS INSTALL_DESTINATION VERSION
#           TARGET_GROUP TARGET_NAMESPACE DEPENDS)
#
# ``NAME``
#   Name of the library.
# ``OBJECTS``
#   Object libraries to combine (see :ref:`yoda_add_library`).
# ``INSTALL_DESTINATION``
#   Destition (relative to ``CMAKE_INSTALL_PREFIX``) to install the libraries.
# ``VERSION``
#   Version of the library
# ``TARGET_GROUP:STRING`` [optional]
#    Target group where the target will be added. The target will be exported in file
#    <INSTALL_DESTINATION>/<TARGET_GROUP>.cmake
# ``TARGET_NAMESPACE:STRING`` [optional]
#    Namespace where the target will be generated
# ``DEPENDS`` [optional]
#   List of external libraries and/or CMake targets treated as dependencies of the library.
#
function(yoda_combine_libraries)
  set(options)
  set(one_value_args NAME INSTALL_DESTINATION VERSION TARGET_GROUP TARGET_NAMESPACE)
  set(multi_value_args OBJECTS DEPENDS)
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  yoda_require_arg("VERSION" ${ARG_VERSION}) 
  yoda_require_arg("INSTALL_DESTINATION" ${ARG_INSTALL_DESTINATION})

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "yoda_combine_libraries: invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT("${ARG_OBJECTS}" STREQUAL ""))
    set(object_sources)
    foreach(object ${ARG_OBJECTS})
      list(APPEND object_sources $<TARGET_OBJECTS:${object}>)
    endforeach()
  endif()

  if(NOT("${ARG_TARGET_GROUP}" STREQUAL ""))
    set(target_group_name ${ARG_TARGET_GROUP})
  else()
    set(target_group_name ${ARG_NAME}Targets)
  endif()

  set(target_namespace)
  if(NOT("${ARG_TARGET_NAMESPACE}" STREQUAL ""))
    set(target_namespace NAMESPACE ${ARG_TARGET_NAMESPACE})
  endif()

  # Add static library
  add_library(${ARG_NAME}Static STATIC ${object_sources})
  target_link_libraries(${ARG_NAME}Static PUBLIC ${ARG_DEPENDS})

  set_target_properties(${ARG_NAME}Static PROPERTIES OUTPUT_NAME ${ARG_NAME})
  set_target_properties(${ARG_NAME}Static PROPERTIES VERSION ${ARG_VERSION})

  install(TARGETS ${ARG_NAME}Static 
          DESTINATION ${ARG_INSTALL_DESTINATION} 
          EXPORT ${target_group_name})
 
  # Add shared library
  if(BUILD_SHARED_LIBS)
    add_library(${ARG_NAME}Shared SHARED ${object_sources})
    target_link_libraries(${ARG_NAME}Shared PUBLIC ${ARG_DEPENDS})
    
    set_target_properties(${ARG_NAME}Shared PROPERTIES OUTPUT_NAME ${ARG_NAME})
    set_target_properties(${ARG_NAME}Shared PROPERTIES VERSION ${ARG_VERSION})
    set_target_properties(${ARG_NAME}Shared PROPERTIES SOVERSION ${ARG_VERSION})

    

    install(TARGETS ${ARG_NAME}Shared 
            DESTINATION ${ARG_INSTALL_DESTINATION} 
            EXPORT ${target_group_name})
  endif()

  # Export the targets
  install(EXPORT ${target_group_name} ${target_namespace} FILE ${target_group_name}.cmake DESTINATION ${CMAKE_INSTALL_PREFIX}/cmake)

endfunction()
