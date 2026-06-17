# Installs the logos-module-loader headers
{ pkgs, common, src }:

pkgs.stdenv.mkDerivation {
  pname = "${common.pname}-headers";
  version = common.version;

  inherit src;
  inherit (common) meta;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/include/logos_module_loader
    cp src/logos_module_loader/*.h $out/include/logos_module_loader/

    runHook postInstall
  '';
}
