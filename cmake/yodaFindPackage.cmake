##===-------------------------------------------------------------------------------------------===##
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(CMakeParseArguments)
include(yodaMakePackageInfo)
include(yodaRequireArg)
include(yodaAddOptionalDeps)
include(yodaGetCacheVariables)
include(yodaCheckVarsAreDefined)

#.rst:
#
# yoda_find_package
# ------------------------
#
# Try to find the package <PACKAGE>. If the package cannot be found via find_package, the 
# file "External_<PACKAGE>" will be included which should define a target <PACKAGE> (in all 
# lower case) which is used to built the package.
#
# The option USE_SYSTEM_<PACKAGE> indicates if the <PACKAGE> (all uppercase) is built or 
# supplied by the system. Note that USE_SYSTEM_<PACKAGE> does not honor the user setting if 
# the package cannot be found (i.e it will build it regardlessly).
#
# .. code-block:: cmake
#
#   yoda_find_package(PACKAGE "package" PACKAGE_ARGS "package_args" 
#           REQUIRED_VARS "required_vars" VERSION_VAR "version_var")
#
#
# ``PACKAGE:STRING``
#   - Name of the package (has to be the same name as used in 
#                               find_package).
# ``NO_DEFAULT_PATH:`` 
#   - This specifies that no system paths should not be used to find packages
# ``PACKAGE_ARGS:LIST``
#   - Arguments passed to find_package.
# ``REQUIRED_VARS:LIST``
#   - Variables which need to be TRUE to consider the package as 
#                               found. By default we check that <PACKAGE>_FOUND is TRUE.
# ``VERSION_VAR:STRING``
#   - Name of the variable which is defined by the find_package command
#                               to provide the version. By default we use <PACKAGE>_VERSION (or a 
#                               variation thereof).
# ``BUILD_VERSION:STRING``
#   - Version of the package which is built (if required)
#
macro(yoda_find_package)
  set(options NO_DEFAULT_PATH)
  set(one_value_args PACKAGE BUILD_VERSION VERSION_VAR)
  set(multi_value_args PACKAGE_ARGS REQUIRED_VARS FORWARD_VARS DEPENDS ADDITIONAL )
  cmake_parse_arguments(ARG "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  yoda_require_arg("PACKAGE" ${ARG_PACKAGE})

  if(NOT("${ARG_UNPARSED_ARGUMENTS}" STREQUAL ""))
    message(FATAL_ERROR "invalid argument ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  string(TOUPPER ${ARG_PACKAGE} package_upper)

  # Define the external file to include if we cannot find the package
  set(external_file External_${ARG_PACKAGE})

  # Define the name of the target *if* we built it (targets are always lower-case for us)
  string(TOLOWER ${ARG_PACKAGE} target)

  set(version "${ARG_BUILD_VERSION}")

  # Do we use the system package or build it from source? 
  set(doc "Should we use the system ${ARG_PACKAGE}?")
  set(default_use_system ON)
  if(NO_SYSTEM_LIBS)
    set(default_use_system OFF)
  endif()

  option(USE_SYSTEM_${package_upper} ${doc} ${default_use_system})

  set(use_system FALSE)
  if(NOT(USE_SYSTEM_${package_upper}))

    ## CALL External_<pkg>

    set(USE_SYSTEM_${package_upper} OFF CACHE BOOL ${doc} FORCE)
    include(${external_file})

    set(CMAKE_ARGS)
    yoda_get_cache_variables(CMAKE_ARGS)
    set(forward_params "CMAKE_ARGS" ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> ${ARG_ADDITIONAL})
    if(ARG_FORWARD_VARS) 
      set(forward_params ${forward_params} "FORWARD_VARS" ${ARG_FORWARD_VARS})
    endif()
    if(ARG_REQUIRED_VARS) 
      set(forward_params ${forward_params} "REQUIRED_VARS" ${ARG_REQUIRED_VARS})
    endif()
    
    yoda_external_package(${forward_params})
    # we check that all required vars are properly set and forwarded here
    yoda_check_vars_are_defined(ARG_REQUIRED_VARS)
  else()
    # Check if the system has the package

    if(${ARG_NO_DEFAULT_PATH})
      set(find_args NO_DEFAULT_PATH QUIET)
    else()
      set(find_args QUIET)
    endif()
    find_package(${ARG_PACKAGE} ${ARG_PACKAGE_ARGS} ${find_args})
    # Check if all the required variables are set
    set(required_vars_ok TRUE)
    set(missing_required_vars)
    foreach(arg ${ARG_REQUIRED_VARS})
      if(NOT(DEFINED ${arg}) OR ("${${arg}}" MATCHES "NOTFOUND"))
        set(required_vars_ok FALSE)
        set(missing_required_vars "${missing_required_vars} ${arg} ${${arg}}")
      endif()
    endforeach()

    if(NOT(${${ARG_PACKAGE}_FOUND}))
      set(required_vars_ok FALSE)
      set(missing_required_vars "${missing_required_vars}" "${ARG_PACKAGE}_FOUND")
    endif()
    if(NOT(required_vars_ok))
      message(STATUS "Package ${ARG_PACKAGE} not found due to missing:${missing_required_vars}")    
    endif()
    
    ## Check if requirements are fulfilled, and if so find the version found
    if(required_vars_ok AND (${ARG_PACKAGE}_FOUND   OR 
                             ${package_upper}_FOUND OR
                             ${ARG_PACKAGE}_DIR)) 
      set(use_system TRUE)

      # Try to detect the version we just found
      if(DEFINED ARG_VERSION_VAR)
        # Try the user variable
        set(version "${${ARG_VERSION_VAR}}")
      elseif(DEFINED ${ARG_PACKAGE}_VERSION_MAJOR AND 
             DEFINED ${ARG_PACKAGE}_VERSION_MINOR AND 
             DEFINED ${ARG_PACKAGE}_VERSION_PATCH)
        # SemVer (X.Y.Z)
        set(version 
            "${${ARG_PACKAGE}_VERSION_MAJOR}.${${ARG_PACKAGE}_VERSION_MINOR}.${${ARG_PACKAGE}_VERSION_PATCH}")
      elseif(DEFINED ${ARG_PACKAGE}_MAJOR_VERSION AND 
             DEFINED ${ARG_PACKAGE}_MINOR_VERSION AND 
             DEFINED ${ARG_PACKAGE}_SUBMINOR_VERSION)
        # Boost SemVer
        set(version 
            "${${ARG_PACKAGE}_MAJOR_VERSION}.${${ARG_PACKAGE}_MINOR_VERSION}.${${ARG_PACKAGE}_SUBMINOR_VERSION}")
      elseif(DEFINED ${ARG_PACKAGE}_VERSION)
        # Standard <PACKAGE>_VERSION
        set(version "${${ARG_PACKAGE}_VERSION}")
      elseif(DEFINED ${package_upper}_VERSION)
        # <PACKAGE>_VERSION with <PACKAGE> all uppercase
        set(version "${${package_upper}_VERSION}")
      else()
        # give up!
        set(version "unknown")
      endif()

    else()

      ## CALL External_<pkg>
    
      set(USE_SYSTEM_${package_upper} OFF CACHE BOOL ${doc} FORCE)
      set(CMAKE_ARGS)
      yoda_get_cache_variables(CMAKE_ARGS)
      include(${external_file})

      set(forward_params "CMAKE_ARGS" ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> ${ARG_ADDITIONAL})
      if(ARG_FORWARD_VARS)
        set(forward_params ${forward_params} "FORWARD_VARS" ${ARG_FORWARD_VARS})
      endif()
      if(ARG_REQUIRED_VARS)
        set(forward_params ${forward_params} "REQUIRED_VARS" ${ARG_REQUIRED_VARS})
      endif()

      yoda_external_package(${forward_params})
      # we check that all required vars are properly set and forwarded here
      yoda_check_vars_are_defined(ARG_REQUIRED_VARS)

    endif()
  endif()

  # Set the dependencies if we build
  if(NOT(use_system) AND ARG_DEPENDS)
    set(deps)
    yoda_add_optional_deps(deps ${ARG_DEPENDS})
    if(deps)
      add_dependencies(${target} ${deps})
    endif()
  endif()

#  yoda_make_package_info(${ARG_PACKAGE} ${version} ${use_system})
endmacro()
