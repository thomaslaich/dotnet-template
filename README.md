# .NET nix templates for multi-project repo

Create .NET projects quickly using nix tooling for developing and building.

Tools used:

- [Nix](https://nixos.org/) + [Flakes](https://serokell.io/blog/practical-nix-flakes)
- [devenv](https://devenv.sh/) and [direnv](https://direnv.net/) for development shell
- [just](https://just.systems/) as a task runner; run `just` in devshell
- [nuget-packageslock2nix](https://github.com/mdarocha/nuget-packageslock2nix) for generating `nuget` dependency lock files for nix
- [csharpier](https://github.com/belav/csharpier) for opinionated code formatting of C#
- [treefmt](https://github.com/numtide/treefmt-nix) for formatting of all code on the pipeline (C# and nix)

## What this provides

- [single-project](https://github.com/thomaslaich/dotnet-templates/single-project)
- [multi-project](https://github.com/thomaslaich/dotnet-templates/multi-project)

## Getting started

If you don't have `nix` installed, run this first:

```bash
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

To use the `single-project` template, simply run:

```bash
$ nix flake init --template github:thomaslaich/dotnet-templates#single-project
```

Similarly, to use the `multi-project` template, simply run:

```bash
$ nix flake init --template github:thomaslaich/dotnet-templates#multi-project
```
## Note

Much of the .NET code is taken from the book: [C# 12 and .NET 8 – Modern Cross-Platform Development Fundamentals - Eighth Edition](https://www.packtpub.com/product/c-12-and-net-8-modern-cross-platform-development-fundamentals-eighth-edition/9781837635870)

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
Other commands are more specific to the template used; please refer to the `README` for the particular template.