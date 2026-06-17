# Common build configuration shared across all packages
{ pkgs, logosContainer }:

{
  pname = "logos-module-loader";
  version = "0.1.0";

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.ninja
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.nlohmann_json
    pkgs.gtest
    logosContainer
  ];

  cmakeFlags = [
    "-GNinja"
    "-DLOGOS_CONTAINER_ROOT=${logosContainer}"
  ];

  env = {
    LOGOS_CONTAINER_ROOT = "${logosContainer}";
  };

  meta = with pkgs.lib; {
    description = "Module-loader contract: the Qt-free ModuleFormatLoader interface (what format a module is)";
    platforms = platforms.unix;
  };
}
