{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, treefmt-nix, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      treefmtEval = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

    in {
      formatter =
        forEachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          formatting = treefmtEval.${system}.config.build.check self;
          unit-tests = pkgs.stdenv.mkDerivation {
            name = "northwind-unittests";
            src = ./.;
            nativeBuildInputs = with pkgs; [ dotnet-sdk_8 ];
            buildInputs = with pkgs; [ dotnet-sdk_8 ];
            doCheck = true;
            checkPhase = ''
              dotnet test
            '';

            buildPhase = ''
              # make compile
            '';
            installPhase = ''
              mkdir -p $out/bin
            '';
          };
        });

      templates = {
        single-project = {
          description = ''
            Dotnet single-project template.

            Includes a web app, a web api, and a mvc app.
          '';
          path = ./single-project;
        };

        multi-project = {
          description = ''
            Dotnet multi-project template.

            Includes a web app, a web api, and a mvc app.
          '';
          path = ./multi-project;
        };
      };
    };
}
