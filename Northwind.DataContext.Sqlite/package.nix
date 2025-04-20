{
  pkgs,
  dotnet-sdk,
  dotnet-runtime,
}:
pkgs.buildDotnetModule {
  name = "northwind-data-context";
  src = ./.;
  nugetDeps = ../deps.json;
  buildType = "Release";
  packNupkg = true;
  inherit dotnet-sdk dotnet-runtime;
  projectReferences = [
    import
    ../northwind.entitymodels.sqlite
    {
      inherit pkgs dotnet-sdk dotnet-runtime;
    }
  ];
}
