{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
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

              processes.run.exec = "hello";

            }];
          };
        });
    };
}
