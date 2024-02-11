{
  description =
    "An example for a .NET single-project solution packaged with nix";

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

          default = pkgs.buildDotnetModule {
            name = "hello-world";
            src = ./helloworld;

            nugetDeps = nuget-packageslock2nix.lib {
              inherit system;
              name = "hello-world";
              lockfiles = [ ./helloworld/packages.lock.json ];
            };

            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            buildType = "Release";

            executables = [ "HelloWorld" ];
          };
        });

      apps = forEachSystem (system: {
        default = mkApp (self.packages.${system}.default) "HelloWorld";
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

      formatter =
        forEachSystem (system: treefmtEval.${system}.config.build.wrapper);

      checks = forEachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
    };
}
