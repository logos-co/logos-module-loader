#ifndef LOGOS_FORMAT_LOADER_FACTORY_H
#define LOGOS_FORMAT_LOADER_FACTORY_H

#include "module_format_loader.h"
#include <memory>

namespace LogosCore {

// Link-time seam for selecting the default module-format loader implementation.
//
// The definition is provided by whichever format-loader implementation library
// the build links in (e.g. logos-module-loader-qt), upcasting its concrete type
// to this interface. This contract names no implementation, and consumers
// (logos-liblogos) call this instead of constructing a concrete format loader —
// so the implementation is chosen purely at build/link time.
//
// Exactly one provider should be linked. Returns the format-loader instance.
std::shared_ptr<ModuleFormatLoader> makeFormatLoader();

} // namespace LogosCore

#endif // LOGOS_FORMAT_LOADER_FACTORY_H
