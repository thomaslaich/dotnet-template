{
  pkgs,
  dotnet-sdk,
  dotnet-runtime,
}:
pkgs.buildDotnetModule {
  name = "northwind-web";
  src = ./.;
  nugetDeps = ../deps.json;
  buildType = "Release";
  executables = [ "Northwind.Web" ];
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
