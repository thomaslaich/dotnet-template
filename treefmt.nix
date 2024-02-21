{ pkgs, lib, ... }: {
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.csharpier.enable = true;
  programs.yamlfmt.enable = true;
}
