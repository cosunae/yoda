##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(ExternalProject)
include(yodaSetExternalProperties)
include(yodaRequireOnlyOneOf)
include(yodaCheckRequiredVars)
include(yodaCloneRepository)

set(DIR_OF_PROTO_EXTERNAL ${CMAKE_CURRENT_LIST_DIR})  

function(yoda_external_package)
  set(options)
  set(one_value_args URL URL_MD5 DOWNLOAD_DIR SOURCE_DIR GIT_REPOSITORY GIT_TAG YODA_ROOT)
  set(multi_value_args REQUIRED_VARS FORWARD_VARS CMAKE_ARGS)
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  yoda_require_arg("YODA_ROOT" ${ARG_YODA_ROOT})
  yoda_require_only_one_of2(NAME1 "SOURCE_DIR" NAME2 "GIT"
         GROUP1 ${ARG_SOURCE_DIR}
         GROUP2 ${ARG_GIT_REPOSITORY} ${ARG_GIT_TAG})

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  yoda_set_external_properties(NAME "serialbox2" 
    INSTALL_DIR install_dir 
    SOURCE_DIR source_dir
    BINARY_DIR binary_dir
  )

  list(APPEND ARG_CMAKE_ARGS "-DYODA_ROOT=${ARG_YODA_ROOT}")
  # set the install path to bundle project install dir
  set(ARG_CMAKE_ARGS ${ARG_CMAKE_ARGS})

  if(ARG_GIT_REPOSITORY)
    yoda_clone_repository(NAME serialbox2 URL ${ARG_GIT_REPOSITORY} BRANCH ${ARG_GIT_TAG} SOURCE_DIR source_dir )
    ExternalProject_Add(serialbox2
      PREFIX serialbox2-prefix
      SOURCE_DIR ${ARG_SOURCE_DIR}
      SOURCE_SUBDIR "bundle"
      INSTALL_DIR "${install_dir}"
      CMAKE_ARGS ${ARG_CMAKE_ARGS} 
    )
  else()
    ExternalProject_Add(serialbox2
      SOURCE_DIR ${ARG_SOURCE_DIR}
      INSTALL_DIR  ${CMAKE_INSTALL_PREFIX}
      BUILD_ALWAYS 1
      CMAKE_ARGS ${ARG_CMAKE_ARGS}
    )
  endif()

  yoda_check_required_vars(SET_VARS serialbox2_DIR REQUIRED_VARS ${ARG_REQUIRED_VARS})

  if(DEFINED ARG_FORWARD_VARS)
    set(options)
    set(one_value_args BINARY_DIR)
    set(multi_value_args)
    cmake_parse_arguments(ARGFV "${options}" "${one_value_args}" "${multi_value_args}" ${ARG_FORWARD_VARS})

    if(NOT("${ARGFV_UNPARSED_ARGUMENTS}" STREQUAL ""))
      message(FATAL_ERROR "invalid argument for FORWARD_VARS ${ARGFV_UNPARSED_ARGUMENTS}")
    endif()

    set(${ARGFV_BINARY_DIR} ${binary_dir} PARENT_SCOPE)

  endif()

  set(serialbox2_DIR "${install_dir}/cmake" CACHE INTERNAL "")

endfunction()
