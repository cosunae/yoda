ReleaseNotes
=============

Changes in **1.01.00**  -  Carlos Osuna
 * Automatically add ``-DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>`` to all packages
   trigger with ``External_XXX`` (no need anymore to add it from user bundle)
 * change of API in ``yoda_add_executable`` (distinguishing LIBRARIES and DEPENDS)
 * Add macro ``yoda_create_library`` that propagate properties of targets
 * Add a macro to print all properties of a target ``yoda_print_target_properties``

Changes in **1.00.00** 29.07.2018 Carlos Osuna
 * First release

