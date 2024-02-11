# .NET nix template for multi-project repo

## Getting started

Create .NET development environment quickly by running:

```bash
$ nix flake init --template github:thomaslaich/dotnet-templates#multi-project
```

If you don't have `nix` installed, run this first:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Specific commands for this template

To build a single app, e.g., `mvc`:

```bash
$ just build mvc
```

Possible values are:

- `entity-models` (for `Northwind.EntityModels.Sqlite`)
- `data-context` (for `Northwind.DataContext.Sqlite`)
- `web` (for `Northwind.Web`)
- `webapi` (for `Northwind.WebApi`)
- `mvc` (for `Northwind.Mvc`)

## Run an app

To run an application, e.g., `mvc`:

```bash
$ just run mvc
```
