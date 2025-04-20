{
  pkgs,
  dotnet-sdk,
  dotnet-runtime,
}:
pkgs.buildDotnetModule {
  name = "northwind-unittests";
  src = ./.;
  nugetDeps = ../deps.json;
  buildType = "Release";
  doCheck = true;
  inherit dotnet-sdk dotnet-runtime;
  projectReferences = [
    import
    ../northwind.data-context.sqlite
    { inherit pkgs dotnet-sdk dotnet-runtime; }
    import
    ../northwind.entitymodels.sqlite
    { inherit pkgs dotnet-sdk dotnet-runtime; }
  ];
}
