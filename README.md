# logos-module-loader

The **module-loader contract** for the Logos module runtime: the 
header-only `ModuleFormatLoader` interface — the "what format is this module"
strategy (Qt plugin, WASM, …) that resolves a host binary and builds its CLI
arguments. It says nothing about *where* a module runs (that is the
`ModuleContainer`'s job, in [`logos-container`](https://github.com/logos-co/logos-container)).

It is the loader-side mirror of `logos-container`: a tiny contract package that
both an implementation (`logos-module-loader-qt`) and `logos-liblogos` depend
*down* onto, so a format loader can be swapped without touching the core.

```
logos-container        (ModuleContainer + ModuleDescriptor value types)
   └─ logos-module-loader        <-- this repo (ModuleFormatLoader interface)
         ├─ logos-module-loader-qt   implements it (QtPluginFormatLoader + logos_host)
         └─ logos-liblogos           consumes the contract
```

## Scope

This package is the format-loader interface plus a link-time factory seam.
`module_format_loader.h` declares the `ModuleFormatLoader` interface (and
consumes `ModuleDescriptor` from `logos-container`, so it depends on that
contract; it does not depend on liblogos). `format_loader_factory.h` declares
`LogosCore::makeFormatLoader()`, which a consumer (liblogos) calls to obtain the
build's default loader without naming a concrete type — the *definition* is
provided by whichever implementation library is linked in (e.g.
`logos-module-loader-qt`). The `ModuleLoader` base and the `CompositeModuleLoader`
/ `ModuleLoaderRegistry` orchestration are core concerns and live in
`logos-liblogos`.

Header-only: the CMake target is an `INTERFACE` library and the nix package is
just the installed headers.

## Build & test

```bash
nix build .#logos-module-loader                # the installed header
nix build .#checks.aarch64-linux.tests -L      # run the contract test
```

Consume it from CMake via the `logos_module_loader` INTERFACE target, or include
the header directly as `<logos_module_loader/module_format_loader.h>`.
