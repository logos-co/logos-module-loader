# The module-loader contract: the Qt-free ModuleFormatLoader interface — the
# "what format is this module" strategy (Qt plugin, WASM, ...) that resolves a
# host binary and builds its CLI args. Header-only — there is nothing to
# compile, so this is an INTERFACE library.
#
# The ModuleDescriptor it consumes lives in the logos-container contract, so
# this package depends down onto logos-container. The ModuleLoader base and the
# composite/registry orchestration are core concerns and live in logos-liblogos.
add_library(logos_module_loader INTERFACE)

# logos-container provides <logos_container/module_descriptor.h> (and nlohmann
# transitively). Imported as a header-only INTERFACE target keyed on its include
# dir.
if(NOT DEFINED LOGOS_CONTAINER_ROOT OR NOT EXISTS "${LOGOS_CONTAINER_ROOT}/include")
  message(FATAL_ERROR "LOGOS_CONTAINER_ROOT not set or ${LOGOS_CONTAINER_ROOT}/include missing")
endif()

add_library(logos_container INTERFACE IMPORTED)
set_target_properties(logos_container PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${LOGOS_CONTAINER_ROOT}/include"
  INTERFACE_LINK_LIBRARIES "nlohmann_json::nlohmann_json"
)

target_link_libraries(logos_module_loader INTERFACE
    logos_container
)

# Both include spellings resolve:
#   <logos_module_loader/module_format_loader.h>  (cross-repo)
#   "module_format_loader.h"                       (bare)
target_include_directories(logos_module_loader INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/logos_module_loader>
    $<INSTALL_INTERFACE:include>
    $<INSTALL_INTERFACE:include/logos_module_loader>
)
