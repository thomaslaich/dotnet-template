{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, nuget-packageslock2nix
    , treefmt-nix, ... }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      mkApp = drv: name: {
        type = "app";
        program = "${drv}/lib/${name}";
      };
      treefmtEval = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

    in {
      packages = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in rec {
          devenv-up = self.devShells.${system}.default.config.procfileScript;

          entity-models = pkgs.buildDotnetModule {
            name = "northwind-entity-models";
            src = ./northwind.entitymodels.sqlite;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "northwind-entity-models";
              lockfiles =
                [ ./northwind.entitymodels.sqlite/packages.lock.json ];
            };

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            packNupkg = true;
          };

          data-context = pkgs.buildDotnetModule {
            name = "northwind-data-context";
            src = ./northwind.datacontext.sqlite;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "northwind-data-context";
              lockfiles = [ ./northwind.datacontext.sqlite/packages.lock.json ];
            };

            projectReferences = [ entity-models ];

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            packNupkg = true;
          };

          web = pkgs.buildDotnetModule {
            name = "northwind-web";
            src = ./northwind.web;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "northwind-web";
              lockfiles = [ ./northwind.web/packages.lock.json ];
            };

            projectReferences = [ data-context entity-models ];

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            buildType = "Release";

            executables = [ "Northwind.Web" ];
          };

          webapi = pkgs.buildDotnetModule {
            name = "northwind-webapi";
            src = ./northwind.webapi;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "northwind-webapi";
              lockfiles = [ ./northwind.webapi/packages.lock.json ];
            };

            projectReferences = [ data-context entity-models ];

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            buildType = "Release";

            executables = [ "Northwind.WebApi" ];
          };

          mvc = pkgs.buildDotnetModule {
            name = "northwind-mvc";
            src = ./northwind.mvc;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "northwind-mvc";
              lockfiles = [ ./northwind.mvc/packages.lock.json ];
            };

            projectReferences = [ data-context entity-models ];

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            buildType = "Release";

            executables = [ "Northwind.Mvc" ];
          };
        });

      apps = forEachSystem (system: {
        web = mkApp (self.packages.${system}.web) "Northwind.Web";
        webapi = mkApp (self.packages.${system}.webapi) "Northwind.WebApi";
        mvc = mkApp (self.packages.${system}.mvc) "Northwind.Mvc";
      });

      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};

        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [{
              packages = with pkgs; [
                cowsay
                lolcat
                just # task runner
                sqlite # sqlite3 db for now
                dotnet-sdk_8 # .NET SDK version 8
              ];

              enterShell = ''
                export DOTNET_ROOT=${pkgs.dotnet-sdk_8}
                cowsay "Welcome to .NET dev shell" | lolcat
              '';
            }];
          };
        });

      formatter = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in { formatting = treefmtEval.${system}.config.build.check self; });
    };
}
