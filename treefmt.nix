{ pkgs, lib, ... }: {
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  settings.formatter = {
    "csharpier" = {
      command = "${pkgs.dotnet-sdk_8}/bin/dotnet";
      options = [ "csharpier" ];
      includes = [ "*.cs" ];
    };
  };
}
