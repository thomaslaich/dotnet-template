{
  pkgs,
  dotnet-sdk,
  dotnet-runtime,
}:
pkgs.buildDotnetModule {
  name = "northwind-mvc";
  src = ./.;
  nugetDeps = ../deps.json;
  buildType = "Release";
  executables = [ "Northwind.Mvc" ];
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
