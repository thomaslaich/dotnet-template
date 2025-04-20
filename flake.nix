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
          dotnet-sdk = pkgs.dotnet-sdk_9;
          dotnet-runtime = pkgs.dotnet-runtime_9;

        in

        rec {
          devenv-up = self.devShells.${system}.default.config.procfileScript;

          web = import ./northwind.web/package.nix {
            inherit pkgs dotnet-sdk dotnet-runtime;
          };

          webapi = import ./northwind.webapi/package.nix {
            inherit pkgs dotnet-sdk dotnet-runtime;
          };

          mvc = import ./northwind.mvc/package.nix {
            inherit pkgs dotnet-sdk dotnet-runtime;
          };

        }
      );

      apps = forEachSystem (system: {
        web = mkApp self.packages.${system}.web "Northwind.Web";
        webapi = mkApp self.packages.${system}.webapi "Northwind.WebApi";
        mvc = mkApp self.packages.${system}.mvc "Northwind.Mvc";
      });

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          dotnet-sdk =
            with pkgs.dotnetCorePackages;
            combinePackages [
              sdk_9_0-bin
              sdk_8_0-bin
            ];

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
                  dotnet-sdk

                  nuget-to-json
                ];

                scripts.restore.exec = ''
                  # restore all projects
                  dotnet tool restore
                  dotnet restore --packages out
                  nuget-to-json out > deps.json
                '';

                enterShell = ''
                  export DOTNET_ROOT=${dotnet-sdk}/share/dotnet
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
          dotnet-sdk = pkgs.dotnet-sdk_9;
          dotnet-runtime = pkgs.dotnet-runtime_9;

        in
        {
          formatting = treefmtEval.${system}.config.build.check self;
          unittests = import ./northwind.unittests/package.nix {
            inherit pkgs dotnet-sdk dotnet-runtime;
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
