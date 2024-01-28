{ pkgs, lib, ... }: {
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  settings.formatter = {
    "csharpier" = {
      command = pkgs.writeShellApplication {
        name = "csharpier-fix";
        runtimeInputs = with pkgs; [ dotnet-sdk csharpier ];
        text = ''
          dotnet-csharpier "$@"
        '';
      };
      includes = [ "*.cs" ];
    };
  };
}
