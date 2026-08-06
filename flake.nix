{
  description = "Module-loader contract: the Qt-free ModuleFormatLoader interface";

  inputs = {
    logos-nix.url = "github:logos-co/logos-nix";
    nixpkgs.follows = "logos-nix/nixpkgs";
    logos-container.url = "github:logos-co/logos-container";
    # so an override of logos-nix reaches logos-container too
    logos-container.inputs.logos-nix.follows = "logos-nix";
  };

  outputs = { self, nixpkgs, logos-nix, logos-container }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
        logosContainer = logos-container.packages.${system}.default;
      });

      # Same, plus "x86_64-windows". Not logos-nix's shared forAllTargets,
      # because this flake threads logosContainer through -- a header-only
      # contract compiled into the target, so it follows the TARGET.
      forAllTargets = f:
        nixpkgs.lib.genAttrs (systems ++ [ "x86_64-windows" ]) (system: f {
          inherit system;
          pkgs =
            if system == "x86_64-windows"
            then logos-nix.lib.mkWindowsPkgs { buildSystem = "x86_64-linux"; }
            else import nixpkgs { inherit system; };
          logosContainer = logos-container.packages.${system}.default;
        });
    in
    {
      packages = forAllTargets ({ pkgs, system, logosContainer, ... }:
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
