# .NET nix template for multi-project repo

Create .NET development environment quickly by running:

```bash
$ nix flake init --template github:thomaslaich/dotnet-template
```

If you don't have `nix` installed, run this first:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Tools used:

- [Nix](https://srid.ca/haskell-nix) + [Flakes](https://serokell.io/blog/practical-nix-flakes)
- [devenv](https://devenv.sh/) and [direnv](https://direnv.net/) for development shell
- [just](https://just.systems/) as a task runner; run `just` in devshell
- [nuget-packageslock2nix](https://github.com/mdarocha/nuget-packageslock2nix) for generating `nuget` dependency lock files for nix
- [csharpier](https://github.com/belav/csharpier) for opinionated code formatting of C#
- [treefmt](https://github.com/numtide/treefmt-nix) for formatting of all code on the pipeline (C# and nix)

## Note

The .NET code is taken from the book: [C# 12 and .NET 8 – Modern Cross-Platform Development Fundamentals - Eighth Edition](https://www.packtpub.com/product/c-12-and-net-8-modern-cross-platform-development-fundamentals-eighth-edition/9781837635870)

The template repo can be found here: [https://github.com/markjprice/cs12dotnet8/tree/main/code/PracticalApps](https://github.com/markjprice/cs12dotnet8/tree/main/code/PracticalApps)

This repo merely adds a nix flake that provides a development environment as well as packaged applications that can be run in isolation.

## Develop

Simply run the following command from the root of the project:

```bash
$ nix develop --impure
```

This will install a .NET SDK in version 8 and all other required dependencies in a completely isolated way (they will not interfere
with any system installations of .NET SDK or any other software).

For even better ergonomics, install [direnv](https://direnv.net/) using your favourite package manager. After that, just `cd` into the directory.
(Note that you might have to run `direnv allow` inside the directory once.)

When using `vscode` or `emacs`, use the corresponding `direnv` extension:
- [direnv for VSCode](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv)
- [direnv for Rider](https://plugins.jetbrains.com/plugin/19275-better-direnv)
- [direnv for Emacs](https://melpa.org/#/direnv)

## Restore

To restore the entire solution (which creates `packages.lock.json` files that are also used for packaging):

```bash
$ just restore
```

## Build

To build the entire solution:

```bash
$ just build
```

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

