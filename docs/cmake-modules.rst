Installation & Use
===================

Add the ``<yoda>/cmake/modules`` directory to the ``CMAKE_MODULE_PATH`` to use the functions, macros and modules:

.. code-block:: cmake

  list(APPEND CMAKE_MODULE_PATH "<yoda>/cmake/")

Note that all `yoda` projects contain a ``yoda_cmake_init`` macro which tries to find the CMake modules of yoda.

.. code-block:: cmake

  include(yodaCMakeInit)
  yoda_cmake_init()


.. include:: user_manual.rst


CMake Modules Reference
=========================

This section describes the CMake functionailty of yoda.

Functions & Macros
-------------------

Each function and macro uses a `snake-case <https://en.wikipedia.org/wiki/Snake_case>`_ identifier and is defined in a separate file using the corresponding `camel-case <https://en.wikipedia.org/wiki/Camel_case>`_ filename. For example, to use the function ``yoda_add_target_clean_all`` include the file ``yodaAddTargetCleanAll`` as follows.

.. code-block:: cmake

    include(yodaAddTargetCleanAll)
    yoda_add_target_clean_all()

List of all functions and macros

.. toctree::
  :maxdepth: 1

  /cmake-modules/External_Boost
  /cmake-modules/External_Clang
  /cmake-modules/External_GTClang
  /cmake-modules/External_GridTools
  /cmake-modules/External_Protobuf
  /cmake-modules/External_cosmo-prerelease-gtclang
  /cmake-modules/External_dawn
  /cmake-modules/External_gtclang
  /cmake-modules/External_serialbox2
  /cmake-modules/yodaAddCustomDummyTarget
  /cmake-modules/yodaAddExecutable
  /cmake-modules/yodaAddLibrary
  /cmake-modules/yodaAddOptionalDeps
  /cmake-modules/yodaAddTargetClangFormat
  /cmake-modules/yodaAddTargetCleanAll
  /cmake-modules/yodaAddUnittest
  /cmake-modules/yodaCheckAndSetCXXFlag
  /cmake-modules/yodaCheckCXXFlag
  /cmake-modules/yodaCheckInSourceBuild
  /cmake-modules/yodaCheckRequiredVars
  /cmake-modules/yodaCheckVarsAreDefined
  /cmake-modules/yodaCloneRepository
  /cmake-modules/yodaCombineLibraries
  /cmake-modules/yodaConfigureFile
  /cmake-modules/yodaCreateLibrary
  /cmake-modules/yodaCreatePackageString
  /cmake-modules/yodaCreatePackageString2
  /cmake-modules/yodaEnableFullRPATH
  /cmake-modules/yodaExportOptions
  /cmake-modules/yodaExportPackage
  /cmake-modules/yodaFindPackage
  /cmake-modules/yodaFindPythonModule
  /cmake-modules/yodaGenerateCMakeScript
  /cmake-modules/yodaGetArchitectureInfo
  /cmake-modules/yodaGetCacheVariables
  /cmake-modules/yodaGetCompilerInfo
  /cmake-modules/yodaGetGitHeadRevision
  /cmake-modules/yodaGetPlatformInfo
  /cmake-modules/yodaGetScriptDir
  /cmake-modules/yodaIncludeGuard
  /cmake-modules/yodaInit
  /cmake-modules/yodaMakeCMakeScript
  /cmake-modules/yodaMakePackageInfo
  /cmake-modules/yodaMakeStringPair
  /cmake-modules/yodaPrintTargetProperties
  /cmake-modules/yodaReportResult
  /cmake-modules/yodaRequireArg
  /cmake-modules/yodaRequireOnlyOneOf
  /cmake-modules/yodaSetCXXStandard
  /cmake-modules/yodaSetDownloadDir
  /cmake-modules/yodaSetExternalProperties


Modules
--------

Load settings for an external project via `find_package <https://cmake.org/cmake/help/v3.0/command/find_package.html>`_.


.. toctree::
  :maxdepth: 1

  /cmake-modules/FindClang
  /cmake-modules/FindGridTools
  /cmake-modules/FindLLVM
  /cmake-modules/FindSLURM
  /cmake-modules/FindSphinx
  /cmake-modules/Findbash
  /cmake-modules/Findccache
  /cmake-modules/Findclang-format
