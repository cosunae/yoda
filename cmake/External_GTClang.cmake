##===-------------------------------------------------------------------------------------------===##
##                        _..._                                                          
##                     .-'_..._''.                                    .---._______       
##  __  __   ___     .' .'      '.\  .         /|                 .--.|   |\  ___ `'.    
## |  |/  `.'   `.  / .'           .'|         ||                 |__||   | ' |--.\  \   
## |   .-.  .-.   '. '            <  |         ||                 .--.|   | | |    \  '  
## |  |  |  |  |  || |             | |         ||  __             |  ||   | | |     |  ' 
## |  |  |  |  |  || |             | | .'''-.  ||/'__ '.   _    _ |  ||   | | |     |  | 
## |  |  |  |  |  |. '             | |/.'''. \ |:/`  '. ' | '  / ||  ||   | | |     ' .' 
## |  |  |  |  |  | \ '.          .|  /    | | ||     | |.' | .' ||  ||   | | |___.' /'  
## |__|  |__|  |__|  '. `._____.-'/| |     | | ||\    / '/  | /  ||__||   |/_______.'/   
##                     `-.______ / | |     | | |/\'..' /|   `'.  |    '---'\_______|/    
##                              `  | '.    | '.'  `'-'` '   .'|  '/                      
##                                 '---'   '---'         `-'  `--'                       
##
##  This file is distributed under the MIT License (MIT). 
##  See LICENSE.txt for details.
##
##===------------------------------------------------------------------------------------------===##

include(ExternalProject)
include(GTClangAddOptionalDeps)
include(GTClangAllMakeCMakeScript)

set(gtclang_cmake_args ${GTCLANG_ALL_CMAKE_ARGS})
foreach(option ${GTCLANG_OPTIONS})
  list(APPEND gtclang_cmake_args "-D${option}:BOOL=${${option}}")
endforeach()

set(gtclang_source "${GTCLANG_ALL_GTCLANG_SOURCE_DIR}")
set(gtclang_build "${CMAKE_CURRENT_BINARY_DIR}/gtclang")

gtclang_all_add_optional_deps(gtclang_deps boost clang)

ExternalProject_Add(gtclang
   DOWNLOAD_DIR ${GTCLANG_ALL_DOWNLOAD_DIR}
   SOURCE_DIR ${gtclang_source}
   BINARY_DIR ${gtclang_build}
   INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"
   CMAKE_ARGS
     ${gtclang_cmake_args}
   DEPENDS
     ${gtclang_deps}
     dawn
)

gtclang_all_make_cmake_script(${gtclang_source} ${gtclang_build} ${gtclang_cmake_args})
