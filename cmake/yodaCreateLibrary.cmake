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
# .. _yoda_create_library:
#
# yoda_create_library
# -------------------------
#
# Create an object library with target *<TARGET>Objects* and combine the Objects library with the dependencies 
# in a static (and optionally) shared library with names *<TARGET>Objects.a* , *<NAME>Static.a* and 
# *<NAME>Shared.so* respectively. The shared library is compiled if the global CMake variable ``BUILD_SHARED_LIBS``
# is active
# 
# .. code-block:: cmake 
#
#   yoda_create_library(TARGET SOURCES VERSION TARGET_GROUP TARGET_NAMESPACE 
#           INSTALL_DESTINATION OBJECTS LIBRARIES DEPENDS SOURCES PUBLIC_BUILD_INCLUDES 
#           PUBLIC_INSTALL_INCLUDES INTERFACE_BUILD_INCLUDES INTERFACE_INSTALL_INCLUDES 
#           PRIVATE_BUILD_INCLUDES )
#
# ``TARGET:STRING``
#    Target name of the library
# ``SOURCES:STRING=<>``
#    List of source files to be comiled in the library
# ``VERSION:STRING``
#    version of the library
# ``TARGET_GROUP:STRING`` [optional]
#    Target group where the target will be added. The target will be exported in file
#    <INSTALL_DESTINATION>/<TARGET_GROUP>.cmake
# ``TARGET_NAMESPACE:STRING`` [optional]
#    Namespace where the target will be generated
# ``INSTALL_DESTINATION:STRING`` [optional]
#    path to install directory
# ``OBJECTS:STRING=<>`` [optional]
#    Object libraries to include in the library
# ``LIBRARIES:STRING=<>`` [optional]
#    External libraries (not CMake targets) on which the library depends on
# ``DEPENDS:STRING=<>`` [optional]
#    CMake target libraries on which the library depends on
# ``[PUBLIC|INTERFACE|PRIVATE]_[BUILD|INSTALL]_INCLUDES`` [optional]
#    List of include paths to add as property of the target. Different argument keywords are used to 
#    specify PUBLIC, INTERFACE or PRIVATE properties as well as to add it to the BUILD or INSTALL 
#    generator expression
# ``BUILD_SHARED`` [optional]
#    Specifies whether we build shared libraries or not. If not specified, the CMAKE global builtin 
#    BUILD_SHARED_LIBS variable is set.
function(yoda_create_library)

  #
  # Parse arguments
  #
  set(oneValueArgs TARGET TARGET_GROUP INSTALL_DESTINATION TARGET_NAMESPACE BUILD_SHARED)
  set(multiValueArgs OBJECTS LIBRARIES DEPENDS SOURCES PUBLIC_BUILD_INCLUDES PUBLIC_INSTALL_INCLUDES 
            INTERFACE_BUILD_INCLUDES INTERFACE_INSTALL_INCLUDES PRIVATE_BUILD_INCLUDES VERSION)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  yoda_require_arg("TARGET" ${ARG_TARGET})
  yoda_require_arg("VERSION" ${ARG_VERSION})

  if(ARG_INSTALL_DESTINATION)
    set(install_destination ${ARG_INSTALL_DESTINATION})
  else()
    set(install_destination lib)
  endif()

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  #
  # Add object library
  #
  yoda_add_library(
    NAME ${ARG_TARGET}
    SOURCES ${ARG_SOURCES}
    DEPENDS ${ARG_LIBRARIES} ${ARG_DEPENDS}
    OBJECT
  )

  if(NOT("${ARG_OBJECTS}" STREQUAL ""))
    set(OBJECT_SOURCES)
    foreach(object ${ARG_OBJECTS})
      list(APPEND OBJECT_SOURCES $<TARGET_OBJECTS:${object}>)
    endforeach()
  endif()


  ## In case we build with shared library, we need to compile with position independent
  if((NOT ARG_BUILD_SHARED STREQUAL "OFF") AND (BUILD_SHARED_LIBS OR (ARG_BUILD_SHARED STREQUAL "ON")))   
	  set_property(TARGET ${ARG_TARGET}Objects PROPERTY POSITION_INDEPENDENT_CODE 1) 
  endif()

  if(NOT("${ARG_PUBLIC_BUILD_INCLUDES}" STREQUAL "") OR NOT("${ARG_PUBLIC_INSTALL_INCLUDES}" STREQUAL ""))
    set(__include_paths PUBLIC)
    foreach(inc_dir ${ARG_PUBLIC_BUILD_INCLUDES})
      if(${inc_dir} STREQUAL "SYSTEM")
        set(__include_paths SYSTEM PUBLIC) 
        continue()
      else()
        list(APPEND __include_paths $<BUILD_INTERFACE:${inc_dir}>)
        target_include_directories(${ARG_TARGET}Objects ${__include_paths})
        set(__include_paths PUBLIC)
      endif()
    endforeach()
    foreach(inc_dir ${ARG_PUBLIC_INSTALL_INCLUDES})
      set(__include_paths PUBLIC)
      if(${inc_dir} STREQUAL "SYSTEM")
        message(FATAL "SYSTEM keyword is not allowed in the PUBLIC_INSTALL_XXX")
      else()
        list(APPEND __include_paths $<INSTALL_INTERFACE:${inc_dir}>)
        target_include_directories(${ARG_TARGET}Objects ${__include_paths})
      endif()
    endforeach()

    unset(__include_paths)
  endif()

  if(NOT("${ARG_PRIVATE_BUILD_INCLUDES}" STREQUAL ""))
    target_include_directories(${ARG_TARGET}Objects PRIVATE ${ARG_PRIVATE_BUILD_INCLUDES} )
  endif()

  ## Propagate the interface include directories of dependencies
  unset(__include_paths)

  target_include_directories(${ARG_TARGET}Objects PUBLIC ${__include_paths} )
  unset(__include_paths)

  set(opt_arg)
  if(ARG_TARGET_GROUP) 
    set(opt_arg ${opt_arg} TARGET_GROUP ${ARG_TARGET_GROUP})
  endif()
  if(ARG_TARGET_NAMESPACE)
    set(opt_arg ${opt_arg} TARGET_NAMESPACE ${ARG_TARGET_NAMESPACE})
  endif()
  if(ARG_BUILD_SHARED)
    set(opt_arg ${opt_arg} BUILD_SHARED ${ARG_BUILD_SHARED})
  endif(ARG_BUILD_SHARED)

  yoda_combine_libraries(
    NAME ${ARG_TARGET}
    OBJECTS ${ARG_TARGET}Objects ${ARG_OBJECTS}
    INSTALL_DESTINATION ${install_destination} 
    VERSION ${ARG_VERSION}
    ${opt_arg}
  )
endfunction(yoda_create_library)

