{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      systems,
      treefmt-nix,
      ...
    }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      mkApp = drv: name: {
        type = "app";
        program = "${drv}/lib/${name}";
      };
      treefmtEval = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        treefmt-nix.lib.evalModule pkgs ./treefmt.nix
      );

    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in

        rec {
          devenv-up = self.devShells.${system}.default.config.procfileScript;

          entity-models = pkgs.buildDotnetModule {
            name = "northwind-entity-models";
            src = ./northwind.entitymodels.sqlite;

            nugetDeps = ./deps.json;

            dotnet-sdk = pkgs.dotnet-sdk_9;
            dotnet-runtime = pkgs.dotnet-runtime_9;

            packNupkg = true;
          };

          data-context = pkgs.buildDotnetModule {
            name = "northwind-data-context";
            src = ./northwind.datacontext.sqlite;

            nugetDeps = ./deps.json;

            projectReferences = [ entity-models ];

            dotnet-sdk = pkgs.dotnet-sdk_9;
            dotnet-runtime = pkgs.dotnet-runtime_9;

            packNupkg = true;
          };

          web = pkgs.buildDotnetModule {
            name = "northwind-web";
            src = ./northwind.web;

            nugetDeps = ./deps.json;

            projectReferences = [
              data-context
              entity-models
            ];

            dotnet-sdk = pkgs.dotnet-sdk_9;
            dotnet-runtime = pkgs.dotnet-runtime_9;

            buildType = "Release";

            executables = [ "Northwind.Web" ];
          };

          webapi = pkgs.buildDotnetModule {
            name = "northwind-webapi";
            src = ./northwind.webapi;

            nugetDeps = ./deps.json;

            projectReferences = [
              data-context
              entity-models
            ];

            dotnet-sdk = pkgs.dotnet-sdk_9;
            dotnet-runtime = pkgs.dotnet-runtime_9;

            buildType = "Release";

            executables = [ "Northwind.WebApi" ];
          };

          mvc = pkgs.buildDotnetModule {
            name = "northwind-mvc";
            src = ./northwind.mvc;

            nugetDeps = ./deps.json;

            projectReferences = [
              data-context
              entity-models
            ];

            dotnet-sdk = pkgs.dotnet-sdk_9;
            dotnet-runtime = pkgs.dotnet-runtime_9;

            buildType = "Release";

            executables = [ "Northwind.Mvc" ];
          };
        }
      );

      apps = forEachSystem (system: {
        web = mkApp (self.packages.${system}.web) "Northwind.Web";
        webapi = mkApp (self.packages.${system}.webapi) "Northwind.WebApi";
        mvc = mkApp (self.packages.${system}.mvc) "Northwind.Mvc";
      });

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [
              {
                packages = with pkgs; [
                  # Welcome screen
                  cowsay
                  lolcat

                  just # task runner
                  sqlite # sqlite3 db for now
                  dotnet-sdk_9 # .NET SDK version 9

                  nuget-to-json
                ];

                scripts.restore.exec = ''
                  # restore all projects
                  dotnet tool restore
                  dotnet restore --packages out
                  nuget-to-json out > deps.json
                '';

                enterShell = ''
                  export DOTNET_ROOT=${pkgs.dotnet-sdk_9}/share/dotnet
                  cowsay "Welcome to .NET dev shell" | lolcat
                '';
              }
            ];
          };
        }
      );

      formatter = forEachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          formatting = treefmtEval.${system}.config.build.check self;
          unit-tests = pkgs.stdenv.mkDerivation {
            name = "northwind-unittests";
            src = ./.;
            nativeBuildInputs = with pkgs; [ dotnet-sdk_9 ];
            buildInputs = with pkgs; [ dotnet-sdk_9 ];
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
        }
      );

      templates = {
        default = {
          description = ''
            Dotnet multi-project template for Northwind.

            Includes a web app, a web api, and a mvc app.
          '';
          path = ./.;
        };
      };
    };
}
