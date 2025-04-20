{
  pkgs,
  dotnet-sdk,
  dotnet-runtime,
}:
pkgs.buildDotnetModule {
  name = "northwind-entity-models";
  src = ./.;
  nugetDeps = ../deps.json;
  inherit dotnet-sdk dotnet-runtime;
  buildType = "Release";
  packNupkg = true;
}
