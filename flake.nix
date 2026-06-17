{
  description = "Module-loader contract: the Qt-free ModuleFormatLoader interface";

  inputs = {
    logos-nix.url = "github:logos-co/logos-nix";
    nixpkgs.follows = "logos-nix/nixpkgs";
    logos-container.url = "github:logos-co/logos-container/abstract_container";
  };

  outputs = { self, nixpkgs, logos-nix, logos-container }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        logosContainer = logos-container.packages.${system}.default;
      });
    in
    {
      packages = forAllSystems ({ pkgs, system, logosContainer }:
        let
          common = import ./nix/default.nix { inherit pkgs logosContainer; };
          src = ./.;

          build = import ./nix/build.nix { inherit pkgs common src; };

          include = import ./nix/include.nix { inherit pkgs common src; };
          tests = import ./nix/tests.nix { inherit pkgs common build; };

          logos-module-loader = pkgs.symlinkJoin {
            name = "logos-module-loader";
            paths = [ include ];
          };
        in
        {
          logos-module-loader-include = include;
          logos-module-loader-tests = tests;

          logos-module-loader = logos-module-loader;

          default = logos-module-loader;
        }
      );

      checks = forAllSystems ({ pkgs, system, ... }:
        let
          testsPkg = self.packages.${system}.logos-module-loader-tests;
        in
        {
          tests = pkgs.runCommand "logos-module-loader-tests" {
            nativeBuildInputs = [ testsPkg ];
          } ''
            echo "Running logos-module-loader tests..."
            ${testsPkg}/bin/logos_module_loader_tests
            mkdir -p $out
            touch $out/.tests-passed
          '';
        }
      );

      devShells = forAllSystems ({ pkgs, ... }: {
        default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.ninja
            pkgs.pkg-config
          ];
          buildInputs = [
            pkgs.nlohmann_json
            pkgs.gtest
          ];
        };
      });
    };
}
